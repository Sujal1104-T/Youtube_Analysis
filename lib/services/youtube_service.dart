import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/app_constants.dart';

class YouTubeService {
  final http.Client _client = http.Client();

  /// Search for videos by query
  Future<List<Map<String, dynamic>>> searchVideos(String query) async {
    try {
      // Check if query is a URL
      String? videoId = extractVideoId(query);
      
      if (videoId != null) {
        // If it's a URL, fetch details specifically for that video
        final videoDetails = await getVideoDetails(videoId);
        return [videoDetails];
      }

      final url = Uri.parse(
          '${AppConstants.youtubeBaseUrl}/search?part=snippet&q=$query&type=video&maxResults=10&key=${AppConstants.youtubeApiKey}');
      
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        
        return items.map((item) {
          final snippet = item['snippet'];
          return {
            'id': item['id']['videoId'],
            'title': snippet['title'],
            'description': snippet['description'],
            'thumbnail': snippet['thumbnails']['high']['url'],
            'channelTitle': snippet['channelTitle'],
            'publishedAt': snippet['publishedAt'],
          };
        }).toList();
      } else {
        throw Exception('Failed to search videos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Extract Video ID from various YouTube URL formats
  String? extractVideoId(String url) {
    if (!url.contains('http') && !url.contains('youtu')) return null;
    
    RegExp regExp = RegExp(
      r'^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#&?]*).*',
      caseSensitive: false,
      multiLine: false,
    );
    
    final match = regExp.firstMatch(url);
    if (match != null && match.group(7) != null) {
      return match.group(7);
    }
    return null;
  }

  /// Get detailed statistics for a specific video
  Future<Map<String, dynamic>> getVideoDetails(String videoId) async {
    try {
      final url = Uri.parse(
          '${AppConstants.youtubeBaseUrl}/videos?part=snippet,statistics,contentDetails&id=$videoId&key=${AppConstants.youtubeApiKey}');
      
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] == null || data['items'].isEmpty) {
          throw Exception('Video not found');
        }
        
        final item = data['items'][0];
        final snippet = item['snippet'];
        final statistics = item['statistics'];
        
        return {
          'id': videoId,
          'title': snippet['title'],
          'description': snippet['description'],
          'channelTitle': snippet['channelTitle'],
          'thumbnail': snippet['thumbnails']['maxres']?['url'] ?? snippet['thumbnails']['high']['url'],
          'viewCount': _formatCount(statistics['viewCount']),
          'likeCount': _formatCount(statistics['likeCount']),
          'commentCount': _formatCount(statistics['commentCount']),
          'rawViewCount': int.tryParse(statistics['viewCount'] ?? '0') ?? 0,
          'rawLikeCount': int.tryParse(statistics['likeCount'] ?? '0') ?? 0,
          'rawCommentCount': int.tryParse(statistics['commentCount'] ?? '0') ?? 0,
        };
      } else {
        throw Exception('Failed to get video details');
      }
    } catch (e) {
      throw Exception('Error fetching details: $e');
    }
  }

  /// Fetch comments for sentiment analysis (max 100)
  Future<List<String>> getVideoComments(String videoId) async {
    try {
      final url = Uri.parse(
          '${AppConstants.youtubeBaseUrl}/commentThreads?part=snippet&videoId=$videoId&maxResults=100&key=${AppConstants.youtubeApiKey}');
      
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        
        return items.map<String>((item) {
          return item['snippet']['topLevelComment']['snippet']['textDisplay'] ?? '';
        }).toList();
      } else {
        // Comments might be disabled or API limit reached
        return [];
      }
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }

  String _formatCount(String? count) {
    if (count == null) return '0';
    int value = int.tryParse(count) ?? 0;
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return count;
  }

  /// Get search suggestions for a query
  Future<List<String>> getSearchSuggestions(String query) async {
    if (query.isEmpty) return [];
    
    try {
      final googleUrl = 'https://suggestqueries.google.com/complete/search?client=youtube&ds=yt&q=${Uri.encodeComponent(query)}';
      
      // Use a CORS proxy only for Web to avoid "Failed to fetch" errors.
      // Native apps (Android/iOS) don't have CORS restrictions.
      final bool isWeb = identical(0, 0.0); // Simple way to check for web if kIsWeb is not imported
      
      if (isWeb) {
        final url = Uri.parse('https://api.allorigins.win/get?url=${Uri.encodeComponent(googleUrl)}');
        final response = await _client.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final body = data['contents'] as String;
          
          final startIndex = body.indexOf('([');
          final endIndex = body.lastIndexOf('])');
          
          if (startIndex != -1 && endIndex != -1) {
            final jsonStr = body.substring(startIndex + 1, endIndex + 1);
            final decodedData = json.decode(jsonStr);
            final List<dynamic> suggestionsData = decodedData[1];
            return suggestionsData.map<String>((item) => item[0].toString()).toList();
          }
        }
      } else {
        // Direct call for Native (Android/iOS)
        final url = Uri.parse(googleUrl);
        final response = await _client.get(url);

        if (response.statusCode == 200) {
          // The response is usually in the format: window.google.ac.h(["query",[["suggestion1",0],...]])
          // or just the JSON array depending on headers/client.
          final body = response.body;
          final startIndex = body.indexOf('([');
          final endIndex = body.lastIndexOf('])');
          
          if (startIndex != -1 && endIndex != -1) {
            final jsonStr = body.substring(startIndex + 1, endIndex + 1);
            final decodedData = json.decode(jsonStr);
            final List<dynamic> suggestionsData = decodedData[1];
            return suggestionsData.map<String>((item) => item[0].toString()).toList();
          }
        }
      }
      return [];
    } catch (e) {
      print('Error fetching suggestions: $e');
      return [];
    }
  }
}
