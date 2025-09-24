const express = require('express');
const axios = require('axios');
const cors = require('cors'); // Required for Flutter/web frontend to connect

const app = express();
// --- CRITICAL CHANGE: Use environment port for global access ---
const port = process.env.PORT || 3001;

// --- Configuration ---
const YOUTUBE_API_KEY = 'AIzaSyDYKo9rOZN8VgU0ZB6oymvwgsWx01Vymkk'; // <-- REPLACE THIS
const YOUTUBE_BASE_URL = 'https://www.googleapis.com/youtube/v3';

// --- Simulated Database (In-Memory History) ---
let analysisHistory = [];
let historyIdCounter = 1;

// --- Middleware ---
app.use(cors());
app.use(express.json());

// --- Helper Functions ---

// Function to extract video ID from various YouTube URLs
function getYouTubeId(url) {
    // Regex for standard URL, short URL, and embed URL
    const regExp = /^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/;
    const match = url.match(regExp);
    return (match && match[2].length === 11) ? match[2] : null;
}

// Function to simulate a call to the YouTube API
async function callYouTubeApi(endpoint, params = {}) {
    try {
        const response = await axios.get(`${YOUTUBE_BASE_URL}/${endpoint}`, {
            params: {
                key: YOUTUBE_API_KEY,
                ...params,
            }
        });
        return response.data;
    } catch (error) {
        console.error(`YouTube API Error on ${endpoint}:`, error.response?.data?.error || error.message);
        throw new Error(`Failed to fetch data from YouTube API. Check your key and quota.`);
    }
}

// Function to simulate AI Sentiment Analysis (NLP)
// In a real app, this would call an external service (like Google Cloud NLP, OpenAI, or a custom model)
function runSentimentAnalysis(comments) {
    // This is a placeholder that returns a basic, simulated result
    // The real logic would be complex and based on comment text.
    const totalComments = comments.length;

    if (totalComments === 0) {
        return {
            overall_sentiment: 'Neutral',
            score: 0.5,
            positive_count: 0,
            negative_count: 0,
            neutral_count: 0,
            total_comments: 0, // Added to handle zero comments case correctly
            sample_comments: [],
        };
    }

    const positive_count = Math.floor(totalComments * 0.45 + Math.random() * 5);
    const negative_count = Math.floor(totalComments * 0.15 + Math.random() * 5);
    const neutral_count = totalComments - positive_count - negative_count;

    const score = (positive_count - negative_count) / totalComments;

    let overall_sentiment = 'Neutral';
    if (score > 0.1) overall_sentiment = 'Positive';
    if (score < -0.1) overall_sentiment = 'Negative';

    // Get a few sample comments
    const sample_comments = comments.length > 5 ? comments.slice(0, 5) : comments;

    return {
        overall_sentiment,
        score: parseFloat(score.toFixed(3)),
        positive_count,
        negative_count,
        neutral_count,
        total_comments: totalComments,
        sample_comments,
    };
}


// ----------------------------------------------------------------------
// --- API ENDPOINTS ---
// ----------------------------------------------------------------------

/**
 * 1. SEARCH ENDPOINT (for Keywords and URL input)
 * @route POST /api/search
 * @body {string} query - The search term or YouTube URL.
 */
app.post('/api/search', async (req, res) => {
    const { query } = req.body;
    if (!query) {
        return res.status(400).json({ error: 'Query is required.' });
    }

    // Check if the query is a URL
    const videoId = getYouTubeId(query);

    try {
        let results = [];
        let videoIdsToFetch = [];

        if (videoId) {
            // Case 1: Search by URL (Get data for that single video)
            videoIdsToFetch.push(videoId);
        } else {
            // Case 2: Search by Keywords or Channel Name
            const searchResponse = await callYouTubeApi('search', {
                q: query,
                part: 'snippet',
                maxResults: 20, // Get more results for the list view
                type: 'video,channel' // Search for both videos and channels
            });

            // Filter for videos and channels
            const videoItems = searchResponse.items.filter(item => item.id.kind === 'youtube#video');
            const channelItems = searchResponse.items.filter(item => item.id.kind === 'youtube#channel');

            // If a channel is found, prioritize its uploaded videos
            if (channelItems.length > 0) {
                const channelId = channelItems[0].id.channelId;
                const channelVideosResponse = await callYouTubeApi('search', {
                    channelId: channelId,
                    part: 'snippet',
                    maxResults: 20,
                    type: 'video',
                    order: 'date'
                });
                videoIdsToFetch = channelVideosResponse.items.map(item => item.id.videoId);
            } else {
                videoIdsToFetch = videoItems.map(item => item.id.videoId);
            }
        }

        // Fetch detailed video statistics and content details for all found videos
        if (videoIdsToFetch.length > 0) {
            const videoResponse = await callYouTubeApi('videos', {
                id: videoIdsToFetch.join(','),
                part: 'snippet,contentDetails,statistics',
            });

            results = videoResponse.items.map(item => ({
                id: item.id,
                title: item.snippet.title,
                channelTitle: item.snippet.channelTitle,
                description: item.snippet.description,
                thumbnail: item.snippet.thumbnails.high.url,
                publishedAt: item.snippet.publishedAt,
                viewCount: item.statistics?.viewCount,
                likeCount: item.statistics?.likeCount,
                commentCount: item.statistics?.commentCount,
                duration: item.contentDetails.duration, // ISO 8601 duration
            }));
        }

        res.json({
            message: videoId ? 'Video details fetched successfully' : 'Search results fetched successfully',
            results,
        });

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});


/**
 * 2. ANALYZE ENDPOINT (Fetches comments and runs AI Sentiment)
 * @route GET /api/analyze/:videoId
 */
app.get('/api/analyze/:videoId', async (req, res) => {
    const { videoId } = req.params;

    try {
        // --- Step 1: Fetch Video Details (If not already done) ---
        const videoResponse = await callYouTubeApi('videos', {
            id: videoId,
            part: 'snippet,statistics', // Fetch basic info
        });

        if (videoResponse.items.length === 0) {
            return res.status(404).json({ error: 'Video not found.' });
        }
        const videoDetails = videoResponse.items[0];


        // --- Step 2: Fetch Comments ---
        let comments = [];
        let pageToken = null;
        const maxCommentPages = 2; // Limit API calls for quota safety

        for (let i = 0; i < maxCommentPages; i++) {
            const commentResponse = await callYouTubeApi('commentThreads', {
                videoId: videoId,
                part: 'snippet',
                maxResults: 100, // Max per page
                pageToken: pageToken
            });

            // Extract the top-level comment text
            comments = comments.concat(commentResponse.items.map(item =>
                item.snippet.topLevelComment.snippet.textOriginal
            ));

            pageToken = commentResponse.nextPageToken;
            if (!pageToken) break;
        }

        // --- Step 3: Run AI Sentiment Analysis ---
        const sentiment = runSentimentAnalysis(comments);


        // --- Step 4: Combine and Respond ---
        const analysisResult = {
            video: {
                id: videoId,
                title: videoDetails.snippet.title,
                thumbnail: videoDetails.snippet.thumbnails.high.url,
                viewCount: videoDetails.statistics.viewCount,
                commentCount: comments.length, // Actual comments analyzed
            },
            analytics: {
                statistics: videoDetails.statistics,
                sentiment_analysis: sentiment,
                // Placeholder for other deep analytics (tags, suggested keywords, etc.)
                deep_analytics: {
                    top_keywords: ['trending', 'analytics', 'video', 'youtube', 'AI', 'data'],
                    suggested_topic: 'Improve SEO',
                    sample_comments: sentiment.sample_comments,
                }
            }
        };

        res.json(analysisResult);

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});


/**
 * 3. HISTORY: SAVE ENDPOINT (Simulates saving analysis results)
 * @route POST /api/history
 * @body {object} data - The complete analysis result object to save.
 */
app.post('/api/history', (req, res) => {
    const analysisData = req.body;
    if (!analysisData || !analysisData.video) {
        return res.status(400).json({ error: 'Invalid analysis data provided.' });
    }

    const newHistoryItem = {
        id: historyIdCounter++,
        timestamp: new Date().toISOString(),
        ...analysisData
    };

    analysisHistory.unshift(newHistoryItem); // Add to the front for easy viewing
    // Optional: Keep only the last 50 entries
    if (analysisHistory.length > 50) {
        analysisHistory = analysisHistory.slice(0, 50);
    }

    res.status(201).json({
        message: 'Analysis saved to history successfully.',
        item: newHistoryItem
    });
});


/**
 * 4. HISTORY: RETRIEVE ENDPOINT
 * @route GET /api/history
 */
app.get('/api/history', (req, res) => {
    // Returns the in-memory history
    res.json({
        message: 'History retrieved successfully',
        history: analysisHistory
    });
});


/**
 * 5. HISTORY: DELETE ENDPOINT (Clears the in-memory history)
 * @route DELETE /api/history
 */
app.delete('/api/history', (req, res) => {
    analysisHistory = []; // Clear the in-memory array
    historyIdCounter = 1; // Reset counter for clean restart
    res.json({
        message: 'Analysis history cleared successfully.',
        history: analysisHistory
    });
});


// ----------------------------------------------------------------------
// --- Server Start ---
// ----------------------------------------------------------------------
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
    console.log('Endpoints ready:');
    console.log(`  - POST http://localhost:${port}/api/search (Search videos/Get URL data)`);
    console.log(`  - GET  http://localhost:${port}/api/analyze/:videoId (Get deep analytics & sentiment)`);
    console.log(`  - POST http://localhost:${port}/api/history (Save analysis)`);
    console.log(`  - GET  http://localhost:${port}/api/history (Get history)`);
    console.log(`  - DELETE http://localhost:${port}/api/history (Clear history)`);
});