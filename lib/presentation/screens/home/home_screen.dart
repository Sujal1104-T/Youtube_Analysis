import 'package:flutter/material.dart';
import '../analytics/analytics_screen.dart';
import '../compare/compare_screen.dart';
import '../history/history_screen.dart'; // Ensure this is imported for navigation logic
import 'package:insight_tube/services/youtube_service.dart';
import 'package:insight_tube/services/sentiment_service.dart';
import '../results/results_screen.dart';
import '../../../main.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class InsightTubeticsScreen extends StatefulWidget {
  const InsightTubeticsScreen({Key? key}) : super(key: key);

  @override
  _InsightTubeticsScreenState createState() => _InsightTubeticsScreenState();
}

class _InsightTubeticsScreenState extends State<InsightTubeticsScreen> with SingleTickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  final YouTubeService _youtubeService = YouTubeService();
  // ignore: unused_field
  final SentimentService _sentimentService = SentimentService(); // In case we need it here later
  
  bool _isLoading = false;
  bool isKeywordsSelected = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  // Voice Search variables
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    searchController.dispose();
    _fadeController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (!_isListening) {
      // Check permissions first
      var status = await Permission.microphone.status;
      if (status.isDenied) {
        status = await Permission.microphone.request();
        if (status.isDenied) {
          _showError('Microphone permission is required for voice search.');
          return;
        }
      }

      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            setState(() => _isListening = false);
          }
          print('Speech status: $val');
        },
        onError: (val) {
          setState(() => _isListening = false);
          _showError('Voice recognition error: ${val.errorMsg}');
        },
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _lastWords = val.recognizedWords;
              if (_lastWords.isNotEmpty) {
                searchController.text = _lastWords;
                // If the user stops talking, we could auto-search
              }
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _performSearch() async {
    if (searchController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter keywords or a URL to search.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Serverless logic: search using YouTube Data API
      // YouTubeService now handles direct URLs automatically
      
      final results = await _youtubeService.searchVideos(searchController.text);
      
      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No videos found. Try different keywords.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      // Smart Navigation: 
      // If we get exactly one result, it's likely a direct URL match -> Go straight to Analytics
      if (results.length == 1) {
         Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalyticsScreen(
              videoId: results[0]['id'],
              onBackToSearch: () => Navigator.of(context).pop(),
            ),
          ),
        );
      } else {
        // Multiple results -> Show Results List
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              videos: results,
              onBackToSearch: () => Navigator.of(context).pop(),
            ),
          ),
        );
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Search failed: ${e.toString().replaceAll("Exception:", "")}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;

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
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, const Color(0xFF00FFB9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'InsightTube',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: isDarkMode ? Colors.white : const Color(0xFF0A0E27),
                    ),
                  ),
                  Text(
                    'YouTube Analytics',
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
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Navigation Grid with Glassmorphism
                  Container(
                    padding: const EdgeInsets.all(20),
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
                          child: _buildNavItem(Icons.search, 'Search', 'search', true, isDarkMode, primaryColor),
                        ),
                        Expanded(
                          child: _buildNavItem(Icons.bar_chart, 'Analytics', 'analytics', false, isDarkMode, primaryColor),
                        ),
                        Expanded(
                          child: _buildNavItem(Icons.compare_arrows, 'Compare', 'compare', false, isDarkMode, primaryColor),
                        ),
                        Expanded(
                          child: _buildNavItem(Icons.history, 'History', 'history', false, isDarkMode, primaryColor),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Search Videos Section with Glassmorphism
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.1)
                            : Colors.white.withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [primaryColor, const Color(0xFF00FFB9)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.search, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [primaryColor, const Color(0xFF00FFB9)],
                                  ).createShader(bounds),
                                  child: Text(
                                    'Search Videos',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Find and analyze YouTube content',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Keywords/URL Toggle
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => isKeywordsSelected = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: isKeywordsSelected
                                        ? (isDarkMode ? primaryColor.withOpacity(0.2) : primaryColor.withOpacity(0.1))
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: isKeywordsSelected
                                        ? Border.all(color: primaryColor.withOpacity(0.5), width: 1.5)
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: isKeywordsSelected ? const Color(0xFF00FFB9) : Colors.grey[600],
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Keywords',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          color: isKeywordsSelected ? primaryColor : theme.textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => isKeywordsSelected = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: !isKeywordsSelected
                                        ? (isDarkMode ? primaryColor.withOpacity(0.2) : primaryColor.withOpacity(0.1))
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: !isKeywordsSelected
                                        ? Border.all(color: primaryColor.withOpacity(0.5), width: 1.5)
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.link,
                                        color: !isKeywordsSelected ? primaryColor : Colors.grey[600],
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'URL',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          color: !isKeywordsSelected ? primaryColor : theme.textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Search Input with Glow Effect
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF1A1F3A).withOpacity(0.5)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDarkMode
                                  ? primaryColor.withOpacity(0.3)
                                  : const Color(0xFF0099CC).withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: RawAutocomplete<String>(
                            optionsBuilder: (TextEditingValue textEditingValue) async {
                              if (textEditingValue.text.isEmpty || !isKeywordsSelected) {
                                return const Iterable<String>.empty();
                              }
                              return await _youtubeService.getSearchSuggestions(textEditingValue.text);
                            },
                            onSelected: (String selection) {
                              searchController.text = selection;
                              _performSearch();
                            },
                            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                              // Sync our searchController with Autocomplete's controller
                              if (controller.text != searchController.text && searchController.text.isNotEmpty && controller.text.isEmpty) {
                                 controller.text = searchController.text;
                              }
                              controller.addListener(() {
                                searchController.text = controller.text;
                              });

                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                style: theme.textTheme.bodyLarge,
                                decoration: InputDecoration(
                                  hintText: isKeywordsSelected
                                      ? 'Enter keywords to search videos...'
                                      : 'Enter YouTube URL to analyze...',
                                  hintStyle: theme.textTheme.bodyMedium,
                                  border: InputBorder.none,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isListening ? Icons.graphic_eq : Icons.mic,
                                      color: _isListening ? Colors.redAccent : primaryColor.withOpacity(0.6),
                                      size: 22,
                                    ),
                                    onPressed: _toggleListening,
                                    tooltip: 'Voice Search',
                                  ),
                                ),
                                onSubmitted: (_) => _performSearch(),
                              );
                            },
                            optionsViewBuilder: (context, onSelected, options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 8,
                                  borderRadius: BorderRadius.circular(12),
                                  color: isDarkMode ? const Color(0xFF1A1F3A) : Colors.white,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width - 64, // Adjust for padding
                                    constraints: const BoxConstraints(maxHeight: 250),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: primaryColor.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: options.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        final String option = options.elementAt(index);
                                        return InkWell(
                                          onTap: () => onSelected(option),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            child: Row(
                                              children: [
                                                Icon(Icons.search, size: 16, color: primaryColor.withOpacity(0.7)),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    option,
                                                    style: theme.textTheme.bodyLarge?.copyWith(
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Search Button with Gradient
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryColor, const Color(0xFF00FFB9)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _performSearch,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.search, color: Colors.white, size: 20),
                                      SizedBox(width: 10),
                                      Text(
                                        'Search',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Ready to Analyze Section
                  Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, const Color(0xFF00FFB9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.4),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.play_arrow, color: Colors.white, size: 48),
                      ),

                      const SizedBox(height: 20),

                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [primaryColor, const Color(0xFF00FFB9)],
                        ).createShader(bounds),
                        child: Text(
                          'Ready to Analyze Videos',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Search for videos by keywords or paste\na YouTube URL to get started with AI-\npowered analytics',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Feature Tags with Gradient Borders
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildFeatureTag('Smart Search', primaryColor, isDarkMode),
                          _buildFeatureTag('AI Sentiment', secondaryColor, isDarkMode),
                          _buildFeatureTag('Deep Analytics', const Color(0xFF00FFB9), isDarkMode),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
  ),
);
  }

  Widget _buildNavItem(IconData icon, String label, String route, bool isActive, bool isDarkMode, Color primaryColor) {
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
              border: isActive
                  ? Border.all(color: primaryColor, width: 2)
                  : null,
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
        Navigator.push(
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

  Widget _buildFeatureTag(String text, Color color, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}