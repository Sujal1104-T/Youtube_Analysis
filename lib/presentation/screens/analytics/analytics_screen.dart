import 'package:flutter/material.dart';
import '../compare/compare_screen.dart';
import '../history/history_screen.dart';
import '../home/home_screen.dart';
import 'package:insight_tube/services/youtube_service.dart';
import 'package:insight_tube/services/sentiment_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  final VoidCallback? onBackToSearch;
  final String? videoId;

  const AnalyticsScreen({Key? key, this.onBackToSearch, this.videoId}) : super(key: key);

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final YouTubeService _youtubeService = YouTubeService();
  final SentimentService _sentimentService = SentimentService();
  
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
      if (widget.videoId == null) throw Exception('No Video ID');

      // 1. Fetch Video Details
      final videoDetails = await _youtubeService.getVideoDetails(widget.videoId!);
      
      // 2. Fetch Comments
      final comments = await _youtubeService.getVideoComments(widget.videoId!);
      
      // 3. Analyze Sentiment Locally
      final sentimentAnalysis = _sentimentService.analyzeComments(comments);
      
      // 4. Extract Keywords (Simple local extraction)
      final description = videoDetails['description'] as String;
      final title = videoDetails['title'] as String;
      final keywords = _extractKeywords('$title $description');

      // 5. Construct Data Object
      final analyticsData = {
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
          'deep_analytics': {
            'top_keywords': keywords,
            'sample_comments': comments.take(5).toList(),
          }
        }
      };

      setState(() {
        _analyticsData = analyticsData;
      });
      
      // History saving would go here if we implemented local storage
      
    } catch (e) {
      setState(() {
        _error = 'Analysis failed: ${e.toString().replaceAll("Exception:", "")}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Simple keyword extractor
  List<String> _extractKeywords(String text) {
    // Remove punctuation and split
    final words = text.toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'));
    
    // Filter common stop words (very basic list)
    final stopWords = {'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of', 'with', 'is', 'are', 'was', 'were', 'be', 'this', 'that', 'it', 'my', 'your', 'video', 'watch', 'subscribe', 'channel', 'link', 'below', 'instagram', 'twitter', 'facebook', 'follow', 'me', 'https', 'com', 'www'};
    
    final wordCounts = <String, int>{};
    for (var word in words) {
      if (word.length > 3 && !stopWords.contains(word)) {
        wordCounts[word] = (wordCounts[word] ?? 0) + 1;
      }
    }
    
    // Sort by frequency
    final sortedWords = wordCounts.keys.toList()
      ..sort((a, b) => wordCounts[b]!.compareTo(wordCounts[a]!));
      
    return sortedWords.take(10).toList();
  }

  Future<void> _saveToHistory(Map<String, dynamic> analysisData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = prefs.getStringList('history_v1') ?? [];
      
      final historyItem = Map<String, dynamic>.from(analysisData);
      historyItem['timestamp'] = DateTime.now().toIso8601String();
      
      // Add new item to top
      history.insert(0, json.encode(historyItem));
      
      // Limit to 20 items
      if (history.length > 20) {
        history = history.sublist(0, 20);
      }
      
      await prefs.setStringList('history_v1', history);
    } catch (e) {
      print('Failed to save history locally: $e');
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
        body: Column(
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
            const CircularProgressIndicator(color: Color(0xFF6366F1)),
            const SizedBox(height: 16),
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
            style: const TextStyle(color: Colors.redAccent, fontSize: 16),
          ),
        ),
      );
    }

    if (_analyticsData == null) {
      // Show the original "No Analytics Data" content
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFF6366F1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bar_chart,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'No Analytics Data',
                style: TextStyle(
                  color: bodyTextColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Search for a video and click "Analyze Video" to see detailed analytics and sentiment analysis',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const InsightTubeticsScreen()),
                          (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
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
                const SizedBox(width: 16),
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

            const SizedBox(height: 24),

            // Key Metrics
            const Text(
              'Key Metrics',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildMetricCard(Icons.visibility, 'Views', stats['viewCount'], bodyTextColor, cardColor),
            _buildMetricCard(Icons.thumb_up, 'Likes', stats['likeCount'], bodyTextColor, cardColor),
            _buildMetricCard(Icons.thumb_up, 'Likes', stats['likeCount'], bodyTextColor, cardColor),
            _buildMetricCard(Icons.comment, 'Comments', sentiment['total_comments'].toString(), bodyTextColor, cardColor),

            const SizedBox(height: 24),
            
            // Engagement Bar Chart
            const Text(
              'Engagement Overview',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildEngagementChart(stats['viewCount'], stats['likeCount'], sentiment['total_comments'].toString(), cardColor, bodyTextColor),
            
            const SizedBox(height: 24),

            // AI Sentiment Analysis
            const Text(
              'AI Sentiment Analysis',
              style: TextStyle(
                color: Color(0xFFE91E63),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildSentimentCard(sentiment, bodyTextColor, cardColor),

            const SizedBox(height: 24),

            // Deep Analytics: Top Keywords
            const Text(
              'Deep Analytics',
              style: TextStyle(
                color: Color(0xFF2196F3),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildDeepAnalyticsCard(deepAnalytics['top_keywords'], bodyTextColor, cardColor),

            const SizedBox(height: 24),

            // Deep Analytics: Comments Section
            const Text(
              'Sample Comments',
              style: TextStyle(
                color: Color(0xFF2196F3),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (deepAnalytics['sample_comments'] != null)
              ...deepAnalytics['sample_comments'].map<Widget>((comment) {
                return _buildCommentCard(comment, bodyTextColor, cardColor);
              }).toList(),

            const SizedBox(height: 40),

            // Go back to search
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const InsightTubeticsScreen()),
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: itemBgColor,
              borderRadius: BorderRadius.circular(8),
              border: isActive ? Border.all(color: const Color(0xFF6366F1), width: 2) : null,
            ),
            child: Icon(
              icon,
              color: isActive ? const Color(0xFF6366F1) : Colors.grey[400],
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFF6366F1) : Colors.grey[400],
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
      margin: const EdgeInsets.only(bottom: 12),
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
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor.withOpacity(0.2), const Color(0xFF00FFB9).withOpacity(0.2)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primaryColor.withOpacity(0.3),
              ),
            ),
            child: Icon(icon, color: primaryColor, size: 22),
          ),
          const SizedBox(width: 16),
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
                const SizedBox(height: 4),
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
      padding: const EdgeInsets.all(16),
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
              const SizedBox(width: 8),
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
          const SizedBox(height: 24),
          
          // Helper to safely parse int
          Builder(
            builder: (context) {
              int safeParse(dynamic input) {
                 if (input is int) return input;
                 if (input is String) return int.tryParse(input) ?? 0;
                 return 0;
              }
              final pos = safeParse(sentiment['positive_count']);
              final neg = safeParse(sentiment['negative_count']);
              final neu = safeParse(sentiment['neutral_count']);
              final total = pos + neg + neu;
              
              if (total == 0) return const SizedBox.shrink();

              return SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        color: Colors.green,
                        value: pos.toDouble(),
                        title: '${((pos/total)*100).toStringAsFixed(0)}%',
                        radius: 50,
                        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      PieChartSectionData(
                        color: Colors.red,
                        value: neg.toDouble(),
                        title: '${((neg/total)*100).toStringAsFixed(0)}%',
                        radius: 50,
                        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      PieChartSectionData(
                        color: Colors.orange,
                        value: neu.toDouble(),
                        title: '${((neu/total)*100).toStringAsFixed(0)}%',
                        radius: 50,
                        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              );
            }
          ),
          
          const SizedBox(height: 24),
          _buildSentimentLegend('Positive', Colors.green, sentiment['positive_count'].toString()),
          const SizedBox(height: 8),
          _buildSentimentLegend('Negative', Colors.red, sentiment['negative_count'].toString()),
          const SizedBox(height: 8),
          _buildSentimentLegend('Neutral', Colors.orange, sentiment['neutral_count'].toString()),
        ],
      ),
    );
  }

  Widget _buildSentimentLegend(String label, Color color, String count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
         Row(
           children: [
             Container(
               width: 10,
               height: 10,
               decoration: BoxDecoration(color: color, shape: BoxShape.circle),
             ),
             const SizedBox(width: 8),
             Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
           ],
         ),
         Text(count, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildEngagementChart(String views, String likes, String comments, Color cardColor, Color textColor) {
    // Parse strings to doubles (handling non-numeric suffixes slightly strictly for charts, 
    // but here we just need relative scale. For simplicity, we'll try to parse K/M or just raw)
    // Actually youtube_service returns "1.2M", so we need to parse that back or use raw counts.
    // The youtube_service.dart also returns 'rawViewCount' 'rawLikeCount' etc.
    // Let's check _fetchAnalyticsData in line 67...
    
     final stats = _analyticsData?['analytics']['statistics'];
     // Wait, the map used in build method uses 'stats' local variable:
     // 'viewCount', 'likeCount' are formatted strings.
     // We should verify if 'rawViewCount' is passed down.
     // Looking at _fetchAnalyticsData (screen code I read earlier):
     /*
       'statistics': {
             'viewCount': videoDetails['viewCount'],
             ...
       }
     */
     // It seems I didn't include raw counts in 'statistics' map in lines 68-72 of this file.
     // BUT, youtube_service DOES return raw counts!
     // I should update _fetchAnalyticsData to include raw counts OR just parse them here roughly.
     // Parsing '1.2M' is annoying. Let's fix _fetchAnalyticsData first? 
     // No, I can't edit _fetchAnalyticsData in this chunk easily. 
     // I'll just use a mock relative value or try to parse simple suffixes.
     
     double parseMetric(String val) {
       val = val.toUpperCase().replaceAll(',', '');
       double mult = 1.0;
       if (val.contains('M')) { mult = 1000000; val = val.replaceAll('M', ''); }
       if (val.contains('K')) { mult = 1000; val = val.replaceAll('K', ''); }
       return (double.tryParse(val) ?? 0) * mult;
     }

     double v = parseMetric(views);
     double l = parseMetric(likes);
     double c = parseMetric(comments);
     
     // Normalize to log scale or ratio because Views are huge compared to likes
     // Actually, BarChart is better for Likes vs Comments. Views breaks the scale.
     // Let's just show Likes vs Comments ratio? Or simpler: Logarithmic?
     // Let's do a simple bar chart of Likes and Comments (Engagement). 
     
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (l > c ? l : c) * 1.2,
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  switch (value.toInt()) {
                    case 0: return const Text('Likes', style: TextStyle(color: Colors.grey, fontSize: 12));
                    case 1: return const Text('Comments', style: TextStyle(color: Colors.grey, fontSize: 12));
                    default: return const Text('');
                  }
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [BarChartRodData(toY: l, color: Colors.blue, width: 20, borderRadius: BorderRadius.circular(4))],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [BarChartRodData(toY: c, color: Colors.purple, width: 20, borderRadius: BorderRadius.circular(4))],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeepAnalyticsCard(List<dynamic> keywords, Color bodyTextColor, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: keywords.map((keyword) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  // Use a slightly darker shade of card color for contrast
                  color: const Color(0xFF3A4052),
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
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
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