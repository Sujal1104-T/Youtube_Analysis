import 'package:flutter/material.dart';
import '../compare/compare_screen.dart';
import '../history/history_screen.dart';
import '../home/home_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AnalyticsScreen extends StatefulWidget {
  final VoidCallback? onBackToSearch;
  final String? videoId;

  const AnalyticsScreen({Key? key, this.onBackToSearch, this.videoId}) : super(key: key);

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final String _backendUrl = 'https://my-youtube-api.cloudfunctions.net/api';
  Map<String, dynamic>? _analyticsData;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    if (widget.videoId != null) {
      _fetchAnalyticsData();
    } else {
      setState(() {
        _isLoading = false;
        _error = 'No video ID provided for analysis.';
      });
    }
  }

  Future<void> _fetchAnalyticsData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final url = Uri.parse('$_backendUrl/analyze/${widget.videoId}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _analyticsData = data;
        });
        // Save to history after successful analysis
        _saveToHistory(data);
      } else {
        final error = json.decode(response.body)['error'] ?? 'Unknown error';
        setState(() {
          _error = 'Failed to load analytics: $error';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error: $e. Is the backend server running?';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveToHistory(Map<String, dynamic> analysisData) async {
    try {
      final url = Uri.parse('$_backendUrl/history');
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(analysisData),
      );
    } catch (e) {
      print('Failed to save to history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final cardColor = Theme.of(context).cardColor;
    final bodyTextColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;

    return Container(
      decoration: BoxDecoration(
        gradient: isDarkMode
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0A0E27),
                  Color(0xFF151B3B),
                  Color(0xFF0A0E27),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF8FAFC),
                  Color(0xFFE0F2FE),
                  Color(0xFFF8FAFC),
                ],
              ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, Color(0xFF00FFB9)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.play_arrow, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [primaryColor, Color(0xFF00FFB9)],
                ).createShader(bounds),
                child: Text(
                  'InsightTube',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 16),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                ),
              ),
              child: Icon(
                isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round,
                color: primaryColor,
                size: 20,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Navigation Grid
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
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
                    true,
                        () {}, // Current screen, no action needed
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    context,
                    Icons.compare_arrows,
                    'Compare',
                    false,
                        () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CompareScreen(
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

          // Analytics Data Section
          Expanded(
            child: _buildContent(bodyTextColor, cardColor),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Color bodyTextColor, Color cardColor) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF6366F1)),
            SizedBox(height: 16),
            Text(
              'Fetching analytics data...',
              style: TextStyle(color: bodyTextColor),
            ),
          ],
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            _error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.redAccent, fontSize: 16),
          ),
        ),
      );
    }

    if (_analyticsData == null) {
      // Show the original "No Analytics Data" content
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Color(0xFF6366F1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bar_chart,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              SizedBox(height: 32),
              Text(
                'No Analytics Data',
                style: TextStyle(
                  color: bodyTextColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Search for a video and click "Analyze Video" to see detailed analytics and sentiment analysis',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 40),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => InsightTubeticsScreen()),
                          (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE53935),
                    padding: EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Go to Search',
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
        ),
      );
    }

    // Display the fetched analytics data
    final video = _analyticsData!['video'];
    final stats = _analyticsData!['analytics']['statistics'];
    final sentiment = _analyticsData!['analytics']['sentiment_analysis'];
    final deepAnalytics = _analyticsData!['analytics']['deep_analytics'];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Title & Thumbnail
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    video['thumbnail'],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    video['title'],
                    style: TextStyle(
                      color: bodyTextColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Key Metrics
            Text(
              'Key Metrics',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16),
            _buildMetricCard(Icons.visibility, 'Views', stats['viewCount'], bodyTextColor, cardColor),
            _buildMetricCard(Icons.thumb_up, 'Likes', stats['likeCount'], bodyTextColor, cardColor),
            _buildMetricCard(Icons.comment, 'Comments', sentiment['total_comments'].toString(), bodyTextColor, cardColor),

            SizedBox(height: 24),

            // AI Sentiment Analysis
            Text(
              'AI Sentiment Analysis',
              style: TextStyle(
                color: Color(0xFFE91E63),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16),
            _buildSentimentCard(sentiment, bodyTextColor, cardColor),

            SizedBox(height: 24),

            // Deep Analytics: Top Keywords
            Text(
              'Deep Analytics',
              style: TextStyle(
                color: Color(0xFF2196F3),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16),
            _buildDeepAnalyticsCard(deepAnalytics['top_keywords'], bodyTextColor, cardColor),

            SizedBox(height: 24),

            // Deep Analytics: Comments Section
            Text(
              'Sample Comments',
              style: TextStyle(
                color: Color(0xFF2196F3),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16),
            if (deepAnalytics['sample_comments'] != null)
              ...deepAnalytics['sample_comments'].map<Widget>((comment) {
                return _buildCommentCard(comment, bodyTextColor, cardColor);
              }).toList(),

            SizedBox(height: 40),

            // Go back to search
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => InsightTubeticsScreen()),
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE53935),
                  padding: EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Analyze another video',
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
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context,
      IconData icon,
      String label,
      bool isActive,
      VoidCallback onTap,
      ) {
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
              border: isActive ? Border.all(color: Color(0xFF6366F1), width: 2) : null,
            ),
            child: Icon(
              icon,
              color: isActive ? Color(0xFF6366F1) : Colors.grey[400],
              size: 20,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Color(0xFF6366F1) : Colors.grey[400],
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(IconData icon, String label, String value, Color bodyTextColor, Color cardColor) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor.withOpacity(0.2), Color(0xFF00FFB9).withOpacity(0.2)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primaryColor.withOpacity(0.3),
              ),
            ),
            child: Icon(icon, color: primaryColor, size: 22),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white60 : Colors.black54,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: bodyTextColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentCard(Map<String, dynamic> sentiment, Color bodyTextColor, Color cardColor) {
    Color sentimentColor;
    if (sentiment['overall_sentiment'] == 'Positive') {
      sentimentColor = Colors.green;
    } else if (sentiment['overall_sentiment'] == 'Negative') {
      sentimentColor = Colors.red;
    } else {
      sentimentColor = Colors.orange;
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor, // Use dynamic card color
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: sentimentColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Overall Sentiment: ${sentiment['overall_sentiment']}',
                style: TextStyle(
                  color: sentimentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Positive: ${sentiment['positive_count']}',
            style: TextStyle(color: Colors.green, fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            'Negative: ${sentiment['negative_count']}',
            style: TextStyle(color: Colors.red, fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            'Neutral: ${sentiment['neutral_count']}',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDeepAnalyticsCard(List<dynamic> keywords, Color bodyTextColor, Color cardColor) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor, // Use dynamic card color
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Keywords',
            style: TextStyle(
              color: bodyTextColor, // Use dynamic text color
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: keywords.map((keyword) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  // Use a slightly darker shade of card color for contrast
                  color: Color(0xFF3A4052),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  keyword,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(String comment, Color bodyTextColor, Color cardColor) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardColor, // Use dynamic card color
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        comment,
        style: TextStyle(color: bodyTextColor, fontSize: 14), // Use dynamic text color
      ),
    );
  }
}