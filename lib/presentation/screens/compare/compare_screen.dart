import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../analytics/analytics_screen.dart';
import '../history/history_screen.dart';
import '../home/home_screen.dart';
import 'dart:io' show Platform;

class CompareScreen extends StatefulWidget {
  final VoidCallback? onBackToSearch;

  const CompareScreen({Key? key, this.onBackToSearch}) : super(key: key);

  @override
  _CompareScreenState createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  final String _backendUrl = 'http://192.168.0.103:3001/api';
  List<Map<String, dynamic>> _videosToCompare = [];
  bool _isLoading = false;
  String? _errorMessage;

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic theme colors
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final bodyTextColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;

    return Scaffold(
      // Use dynamic colors
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        // Use dynamic colors
        backgroundColor: scaffoldColor,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Color(0xFFE53935),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.play_arrow, color: Colors.white, size: 20),
            ),
            SizedBox(width: 12),
            Text(
              'InsightTube',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              // Use dynamic colors
              color: cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.wb_sunny_outlined, color: Colors.orange, size: 20),
          ),
        ],
      ),
      // FINAL OVERFLOW FIX: Wrap the entire body content in a SingleChildScrollView.
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Navigation Grid
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                // Use dynamic colors
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildNavItem(
                      context,
                      Icons.search,
                      'Search',
                      false,
                          () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => InsightTubeticsScreen()),
                              (route) => false,
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      context,
                      Icons.bar_chart,
                      'Analytics',
                      false,
                          () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnalyticsScreen(
                              onBackToSearch: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => InsightTubeticsScreen()),
                                      (route) => false,
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      context,
                      Icons.compare_arrows,
                      'Compare',
                      true,
                          () {}, // Current screen, no action needed
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      context,
                      Icons.history,
                      'History',
                      false,
                          () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HistoryScreen(
                              onBackToSearch: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => InsightTubeticsScreen()),
                                      (route) => false,
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Comparison Content Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Video Comparison',
                    style: TextStyle(
                      color: bodyTextColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 24),

                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Error: $_errorMessage',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),

                  if (_isLoading)
                    Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),

                  if (!_isLoading && _videosToCompare.length < 2)
                    _buildNoVideosToCompare(bodyTextColor, cardColor),

                  if (!_isLoading && _videosToCompare.length >= 2)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildComparisonCard(_videosToCompare[0], bodyTextColor, cardColor),
                          SizedBox(width: 16),
                          _buildComparisonCard(_videosToCompare[1], bodyTextColor, cardColor),
                          SizedBox(width: 16), // Padding for last card
                        ],
                      ),
                    ),

                  // Add buffer space
                  SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoVideosToCompare(Color bodyTextColor, Color cardColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32),
      margin: EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        // Use dynamic colors
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Color(0xFF6366F1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.compare_arrows,
              color: Colors.white,
              size: 40,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No Videos to Compare',
            style: TextStyle(
              color: bodyTextColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Add videos to start comparing their\nperformance metrics',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              height: 1.5,
            ),
          ),
          SizedBox(height: 32),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showAddVideoDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE53935),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Add Video',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(Map<String, dynamic> data, Color bodyTextColor, Color cardColor) {
    final video = data['video'];
    final stats = data['analytics']['statistics'];
    final sentiment = data['analytics']['sentiment_analysis'];
    final deepAnalytics = data['analytics']['deep_analytics'];
    final keywordsCount = (deepAnalytics['top_keywords'] as List<dynamic>).length.toString();
    final sentimentScore = sentiment['score'].toString();

    return Container(
      width: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Use dynamic colors
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              video['thumbnail'],
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 12),
          Text(
            video['title'],
            style: TextStyle(
              color: bodyTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12),
          _buildComparisonMetric('Views', stats['viewCount'], bodyTextColor),
          _buildComparisonMetric('Likes', stats['likeCount'], bodyTextColor),
          _buildComparisonMetric('Comments', sentiment['total_comments'].toString(), bodyTextColor),
          _buildComparisonMetric('Keywords Found', keywordsCount, bodyTextColor),
          _buildComparisonMetric('Sentiment Score', sentimentScore, bodyTextColor, color: _getSentimentColor(sentiment['overall_sentiment'])),
          _buildComparisonMetric('Overall Sentiment', sentiment['overall_sentiment'], bodyTextColor, color: _getSentimentColor(sentiment['overall_sentiment'])),
        ],
      ),
    );
  }

  Widget _buildComparisonMetric(String label, String value, Color bodyTextColor, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[400]),
          ),
          Text(
            value,
            style: TextStyle(color: color ?? bodyTextColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Color _getSentimentColor(String sentiment) {
    if (sentiment == 'Positive') return Colors.green;
    if (sentiment == 'Negative') return Colors.red;
    return Colors.orange;
  }

  Widget _buildNavItem(
      BuildContext context,
      IconData icon,
      String label,
      bool isActive,
      VoidCallback onTap,
      ) {
    Color activeColor = Color(0xFF6366F1);

    if (label == 'History') {
      activeColor = Color(0xFFFF9800);
    }
    if (label == 'Search') {
      activeColor = Color(0xFFE53935);
    }

    // Dynamic access to theme for background color
    final itemBgColor = Theme.of(context).scaffoldBackgroundColor;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: itemBgColor,
              borderRadius: BorderRadius.circular(8),
              border: isActive ? Border.all(color: activeColor, width: 2) : null,
            ),
            child: Icon(
              icon,
              color: isActive ? activeColor : Colors.grey[400],
              size: 20,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? activeColor : Colors.grey[400],
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddVideoDialog() {
    TextEditingController urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Dynamic dialog colors
        final dialogCardColor = Theme.of(context).cardColor;
        final dialogScaffoldColor = Theme.of(context).scaffoldBackgroundColor;
        final dialogBodyTextColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;

        return Dialog(
          backgroundColor: dialogCardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Padding(
              // Increased padding to definitively absorb the 14px overflow
              padding: EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Video to Compare',
                    style: TextStyle(
                      color: dialogBodyTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: dialogScaffoldColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade700),
                    ),
                    child: TextField(
                      controller: urlController,
                      style: TextStyle(color: dialogBodyTextColor),
                      decoration: InputDecoration(
                        hintText: 'Enter YouTube URL...',
                        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          if (urlController.text.isNotEmpty) {

                            setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            });

                            Navigator.pop(context);

                            try {
                              final url = Uri.parse('$_backendUrl/search');

                              final response = await http.post(
                                url,
                                headers: {'Content-Type': 'application/json'},
                                body: json.encode({'query': urlController.text}),
                              );

                              if (response.statusCode == 200) {
                                final data = json.decode(response.body);
                                if (data['results'] != null && data['results'].isNotEmpty) {
                                  final videoId = data['results'][0]['id'];
                                  final analyzeUrl = Uri.parse('$_backendUrl/analyze/$videoId');
                                  final analyzeResponse = await http.get(analyzeUrl);

                                  if (analyzeResponse.statusCode == 200) {
                                    final analyzeData = json.decode(analyzeResponse.body);
                                    setState(() {
                                      if (_videosToCompare.length < 2) {
                                        _videosToCompare.add(analyzeData);
                                        _errorMessage = null;
                                      } else {
                                        _errorMessage = 'Maximum of 2 videos can be compared.';
                                        _showErrorSnackbar(_errorMessage!);
                                      }
                                    });
                                  } else {
                                    final errorBody = json.decode(analyzeResponse.body);
                                    _errorMessage = errorBody['error'] ?? 'Failed to analyze video.';
                                    _showErrorSnackbar(_errorMessage!);
                                  }
                                } else {
                                  _errorMessage = 'No video found for that URL.';
                                  _showErrorSnackbar(_errorMessage!);
                                }
                              } else {
                                final errorBody = json.decode(response.body);
                                _errorMessage = errorBody['error'] ?? 'Failed to search for video (Status: ${response.statusCode}).';
                                _showErrorSnackbar(_errorMessage!);
                              }
                            } catch (e) {
                              _errorMessage = 'Network error: $e. Check your backend server status (http://192.168.0.103:3001).';
                              _showErrorSnackbar(_errorMessage!);
                            } finally {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFE53935),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Add Video',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}