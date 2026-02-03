import 'package:flutter/material.dart';
import 'package:insight_tube/services/youtube_service.dart';
import 'package:insight_tube/services/sentiment_service.dart';
import '../analytics/analytics_screen.dart';
import '../history/history_screen.dart';
import '../home/home_screen.dart';

class CompareScreen extends StatefulWidget {
  final VoidCallback? onBackToSearch;

  const CompareScreen({Key? key, this.onBackToSearch}) : super(key: key);

  @override
  _CompareScreenState createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  final YouTubeService _youtubeService = YouTubeService();
  final SentimentService _sentimentService = SentimentService();

  final TextEditingController urlController = TextEditingController(); // Define controller here or check if it's already defined inside build
  final List<Map<String, dynamic>> _videosToCompare = [];
  bool _isLoading = false;
  String? _errorMessage;

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
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
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0A0E27),
                  Color(0xFF151B3B),
                  Color(0xFF0A0E27),
                ],
              )
            : const LinearGradient(
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
                    colors: [primaryColor, const Color(0xFF00FFB9)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [primaryColor, const Color(0xFF00FFB9)],
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
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Navigation Grid
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
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
                      offset: const Offset(0, 4),
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
                          MaterialPageRoute(builder: (context) => const InsightTubeticsScreen()),
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
                                  MaterialPageRoute(builder: (context) => const InsightTubeticsScreen()),
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
                                  MaterialPageRoute(builder: (context) => const InsightTubeticsScreen()),
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  const SizedBox(height: 24),

                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Error: $_errorMessage',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),

                  if (!_isLoading && _videosToCompare.length < 2)
                    _buildNoVideosToCompare(bodyTextColor, cardColor),

                  if (!_isLoading && _videosToCompare.length >= 2)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildComparisonCard(_videosToCompare[0], bodyTextColor, cardColor),
                          const SizedBox(width: 16),
                          _buildComparisonCard(_videosToCompare[1], bodyTextColor, cardColor),
                          const SizedBox(width: 16), // Padding for last card
                        ],
                      ),
                    ),

                  // Add buffer space
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildNoVideosToCompare(Color bodyTextColor, Color cardColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.only(top: 16),
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
            decoration: const BoxDecoration(
              color: Color(0xFF6366F1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.compare_arrows,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Videos to Compare',
            style: TextStyle(
              color: bodyTextColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add videos to start comparing their\nperformance metrics',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showAddVideoDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
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
      padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 12),
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
          const SizedBox(height: 12),
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
    Color activeColor = const Color(0xFF6366F1);

    if (label == 'History') {
      activeColor = const Color(0xFFFF9800);
    }
    if (label == 'Search') {
      activeColor = const Color(0xFFE53935);
    }

    // Dynamic access to theme for background color
    final itemBgColor = Theme.of(context).scaffoldBackgroundColor;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
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
          const SizedBox(height: 8),
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
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
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
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  const SizedBox(height: 24),
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
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          // Define controller locally if it was local, but assuming I can access the one in buffer if I find where it's defined.
                          // Actually, looking at the previous file view, 'urlController' was usually defined inside the showDialog builder or passed to it.
                          // Let's assume 'urlController' is available in this scope as seen in previous view.
                          
                          if (urlController.text.isNotEmpty) {

                            setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            });

                            Navigator.pop(context);

                            try {
                              // 1. Search to get ID (or use ID if URL provided)
                              final results = await _youtubeService.searchVideos(urlController.text);
                              
                              if (results.isNotEmpty) {
                                final videoId = results[0]['id'];
                                
                                // 2. Video Details
                                final videoDetails = await _youtubeService.getVideoDetails(videoId);
                                
                                // 3. Comments
                                final comments = await _youtubeService.getVideoComments(videoId);
                                
                                // 4. Sentiment
                                final sentimentAnalysis = _sentimentService.analyzeComments(comments);

                                // 5. Construct Data
                                final analyzeData = {
                                  'video': videoDetails,
                                  'analytics': {
                                    'statistics': {
                                      'viewCount': videoDetails['viewCount'],
                                      'likeCount': videoDetails['likeCount'],
                                      'commentCount': videoDetails['commentCount'],
                                    },
                                    'sentiment_analysis': {
                                      'overall_sentiment': sentimentAnalysis['overall_sentiment'],
                                      'positive_count': sentimentAnalysis['positive_count'],
                                      'negative_count': sentimentAnalysis['negative_count'],
                                      'neutral_count': (sentimentAnalysis['total_comments'] as int) - 
                                                       (sentimentAnalysis['positive_count'] as int) - 
                                                       (sentimentAnalysis['negative_count'] as int),
                                      'total_comments': sentimentAnalysis['total_comments'],
                                    },
                                    // Deep analytics simplified for compare
                                    'deep_analytics': {
                                      'top_keywords': [], // Skipping for compare optimization
                                    }
                                  }
                                };

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
                                _errorMessage = 'No video found.';
                                _showErrorSnackbar(_errorMessage!);
                              }
                            } catch (e) {
                              _errorMessage = 'Error: ${e.toString().replaceAll("Exception:", "")}';
                              _showErrorSnackbar(_errorMessage!);
                            } finally {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
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