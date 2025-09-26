const express = require('express');
const axios = require('axios');
const cors = require('cors'); // Required for Flutter/web frontend to connect

const app = express();
// --- CRITICAL CHANGE: Use environment port for global access ---
const port = process.env.PORT || 3001;

// --- Configuration ---
// UPDATED FOR SECURITY: API Key is now read from the hosting environment.
const YOUTUBE_API_KEY = process.env.YOUTUBE_API_KEY;
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
        if (!YOUTUBE_API_KEY) {
            throw new Error('YOUTUBE_API_KEY is not set in environment variables.');
        }

        const response = await axios.get(`${YOUTUBE_BASE_URL}/${endpoint}`, {
            params: {
                key: YOUTUBE_API_KEY,
                ...params,
            }
        });
        return response.data;
    } catch (error) {
        console.error(`YouTube API Error on ${endpoint}:`, error.response?.data?.error || error.message);
        // The original error message is now wrapped for clarity
        throw new Error(`Failed to fetch data from YouTube API. Check your key and quota.`);
    }
}

// Function to simulate AI Sentiment Analysis (NLP)
// (This placeholder function remains the same)
function runSentimentAnalysis(comments) {
    const totalComments = comments.length;

    if (totalComments === 0) {
        return {
            overall_sentiment: 'Neutral',
            score: 0.5,
            positive_count: 0,
            negative_count: 0,
            neutral_count: 0,
            total_comments: 0,
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
// --- API ENDPOINTS (Remain the same) ---
// ----------------------------------------------------------------------

app.post('/api/search', async (req, res) => {
    // ... search logic
});

app.get('/api/analyze/:videoId', async (req, res) => {
    // ... analyze logic
});

app.post('/api/history', (req, res) => {
    // ... save history logic
});

app.get('/api/history', (req, res) => {
    // ... retrieve history logic
});

app.delete('/api/history', (req, res) => {
    // ... delete history logic
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