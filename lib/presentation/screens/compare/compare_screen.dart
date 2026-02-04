import 'package:flutter/material.dart';
import 'package:insight_tube/services/youtube_service.dart';
import 'package:insight_tube/services/sentiment_service.dart';
import '../analytics/analytics_screen.dart';
import '../history/history_screen.dart';
import '../home/home_screen.dart';
import '../../../main.dart';

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
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                ),
              ),
              child: Icon(
                Icons.arrow_back,
                color: primaryColor,
                size: 20,
              ),
            ),
            onPressed: () {
              if (widget.onBackToSearch != null) {
                widget.onBackToSearch!();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, const Color(0xFF00FFB9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'InsightTube',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white : const Color(0xFF0A0E27),
                    ),
                  ),
                  Text(
                    'Comparison',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
              onPressed: () {
                final appState = MyApp.of(context);
                appState.toggleTheme();
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Navigation Grid
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      child: _buildNavItem(Icons.search, 'Search', 'search', false, isDarkMode, primaryColor),
                    ),
                    Expanded(
                      child: _buildNavItem(Icons.bar_chart, 'Analytics', 'analytics', false, isDarkMode, primaryColor),
                    ),
                    Expanded(
                      child: _buildNavItem(Icons.compare_arrows, 'Compare', 'compare', true, isDarkMode, primaryColor),
                    ),
                    Expanded(
                      child: _buildNavItem(Icons.history, 'History', 'history', false, isDarkMode, primaryColor),
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

                  if (!_isLoading && _videosToCompare.isEmpty)
                    _buildNoVideosToCompare(bodyTextColor, cardColor),

                  if (!_isLoading && _videosToCompare.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildComparisonCard(0, bodyTextColor, cardColor),
                          const SizedBox(width: 16),
                          if (_videosToCompare.length < 2)
                            _buildAddVideoPlaceholder(bodyTextColor, cardColor)
                          else
                            _buildComparisonCard(1, bodyTextColor, cardColor),
                          const SizedBox(width: 16),
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
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.compare_arrows_rounded,
              color: Color(0xFF6366F1),
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Compare Two Videos',
            style: TextStyle(
              color: bodyTextColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add YouTube videos side-by-side to\nanalyze and compare their performance.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showAddVideoDialog,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add First Video'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddVideoPlaceholder(Color bodyTextColor, Color cardColor) {
    return Container(
      width: 300,
      height: 400, // Matching comparison card height approximately
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.3),
          width: 2,
          style: BorderStyle.none, // Will use dotted effect if possible or just simple border
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showAddVideoDialog,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline_rounded,
                color: const Color(0xFF6366F1).withOpacity(0.7),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Add Second Video',
                style: TextStyle(
                  color: bodyTextColor.withOpacity(0.8),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Paste URL to compare',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonCard(int index, Color bodyTextColor, Color cardColor) {
    final data = _videosToCompare[index];
    final video = data['video'];
    final stats = data['analytics']['statistics'];
    final sentiment = data['analytics']['sentiment_analysis'];
    
    // Convert counts to doubles for calculation
    double getRaw(dynamic val) {
       if (val is int) return val.toDouble();
       if (val is String) {
         String clean = val.replaceAll(RegExp(r'[^0-9.]'), '');
         double? d = double.tryParse(clean);
         if (d != null) {
            if (val.contains('M')) return d * 1000000;
            if (val.contains('K')) return d * 1000;
            return d;
         }
       }
       return 0.0;
    }

    final views = getRaw(stats['viewCount']);
    final likes = getRaw(stats['likeCount']);
    final comments = getRaw(sentiment['total_comments']);
    
    final engagementRate = views > 0 ? ((likes + comments) / views * 100) : 0.0;
    
    bool isWinner(String metric, dynamic value) {
      if (_videosToCompare.length < 2) return false;
      int otherIndex = index == 0 ? 1 : 0;
      final otherData = _videosToCompare[otherIndex];
      final otherStats = otherData['analytics']['statistics'];
      final otherSentiment = otherData['analytics']['sentiment_analysis'];

      if (metric == 'Views') return views > getRaw(otherStats['viewCount']);
      if (metric == 'Likes') return likes > getRaw(otherStats['likeCount']);
      if (metric == 'Engagement') {
         final otherViews = getRaw(otherStats['viewCount']);
         final otherER = otherViews > 0 ? ((getRaw(otherStats['likeCount']) + getRaw(otherSentiment['total_comments'])) / otherViews * 100) : 0.0;
         return engagementRate > otherER;
      }
      if (metric == 'Positive') return (sentiment['positive_count'] as int) > (otherSentiment['positive_count'] as int);
      
      return false;
    }

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  video['thumbnail'],
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _videosToCompare.removeAt(index);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video['title'],
                  style: TextStyle(
                    color: bodyTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  video['channelTitle'],
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const Divider(height: 24, thickness: 0.5),
                
                _buildComparisonMetric('Views', stats['viewCount'], bodyTextColor, isWinner: isWinner('Views', null)),
                _buildComparisonMetric('Likes', stats['likeCount'], bodyTextColor, isWinner: isWinner('Likes', null)),
                _buildComparisonMetric('Engagement', '${engagementRate.toStringAsFixed(2)}%', bodyTextColor, isWinner: isWinner('Engagement', null)),
                
                const SizedBox(height: 12),
                const Text('Sentiment Breakdown', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildSentimentBar(sentiment),
                const SizedBox(height: 8),
                
                _buildComparisonMetric('Positive', '${sentiment['positive_count']}', Colors.green, isWinner: isWinner('Positive', null)),
                _buildComparisonMetric('Negative', '${sentiment['negative_count']}', Colors.red),
                _buildComparisonMetric('Overall', sentiment['overall_sentiment'], _getSentimentColor(sentiment['overall_sentiment'])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentBar(Map<String, dynamic> sentiment) {
    final total = sentiment['total_comments'] as int;
    if (total == 0) return const SizedBox.shrink();

    final pos = (sentiment['positive_count'] as int) / total;
    final neg = (sentiment['negative_count'] as int) / total;
    final neu = (sentiment['neutral_count'] as int) / total;

    return Container(
      height: 8,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.grey.withOpacity(0.1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Row(
          children: [
            Expanded(flex: (pos * 100).toInt(), child: Container(color: Colors.green)),
            Expanded(flex: (neu * 100).toInt(), child: Container(color: Colors.orange)),
            Expanded(flex: (neg * 100).toInt(), child: Container(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonMetric(String label, String value, Color bodyTextColor, {Color? color, bool isWinner = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
          Row(
            children: [
              if (isWinner)
                const Padding(
                  padding: EdgeInsets.only(right: 4.0),
                  child: Icon(Icons.stars_rounded, color: Colors.amber, size: 14),
                ),
              Text(
                value,
                style: TextStyle(
                  color: isWinner ? (color ?? const Color(0xFF00FFB9)) : (color ?? bodyTextColor),
                  fontWeight: isWinner ? FontWeight.bold : FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
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
    IconData icon,
    String label,
    String route,
    bool isActive,
    bool isDarkMode,
    Color primaryColor,
  ) {
    return GestureDetector(
      onTap: () {
        _handleNavigation(route);
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive
                  ? (isDarkMode ? primaryColor.withOpacity(0.2) : primaryColor.withOpacity(0.1))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isActive ? Border.all(color: primaryColor, width: 2) : null,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isActive ? primaryColor : Colors.grey[400],
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? primaryColor : Colors.grey[400],
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(String route) {
    switch (route) {
      case 'search':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const InsightTubeticsScreen()),
          (route) => false,
        );
        break;
      case 'analytics':
        Navigator.push(
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
        break;
      case 'compare':
        // Already here
        break;
      case 'history':
        Navigator.push(
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
        break;
    }
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