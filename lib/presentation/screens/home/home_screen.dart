import 'package:flutter/material.dart';
import '../analytics/analytics_screen.dart';
import '../compare/compare_screen.dart';
import '../history/history_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../results/results_screen.dart';
import 'dart:io' show Platform;
import '../../../main.dart'; // <--- ADDED: Import MyApp to access toggleTheme

class InsightTubeticsScreen extends StatefulWidget {
  const InsightTubeticsScreen({Key? key}) : super(key: key);

  @override
  _InsightTubeticsScreenState createState() => _InsightTubeticsScreenState();
}

class _InsightTubeticsScreenState extends State<InsightTubeticsScreen> {
  bool isKeywordsSelected = true;
  TextEditingController searchController = TextEditingController();
  final String _backendUrl = Platform.isAndroid ? 'http://192.168.0.103:3001/api' : 'http://localhost:3001/api';
  bool _isLoading = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _performSearch() async {
    final query = searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter keywords or a URL to search.'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('$_backendUrl/search');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'query': query}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Search successful! Displaying results.'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
          // Navigate to the Results screen and pass the list of videos
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultsScreen(
                videos: List<Map<String, dynamic>>.from(data['results']),
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

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No videos or channels found for "$query"'),
              backgroundColor: Color(0xFFFF9800),
            ),
          );
        }
      } else {
        final error = json.decode(response.body)['error'] ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error. Please ensure the backend is running.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Uses the Theme's current brightness to determine the mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // Uses Theme data colors from main.dart
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      // Use dynamic colors
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        // Use dynamic colors
        backgroundColor: scaffoldColor,
        elevation: 0,
        automaticallyImplyLeading: false,
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
            child: GestureDetector(
              onTap: () {
                // FIXED: Call the toggleTheme method from MyAppState
                MyApp.of(context).toggleTheme();
              },
              child: Icon(
                isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round,
                color: Colors.orange,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Navigation Grid
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // Use dynamic colors
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildNavItem(Icons.search, 'Search', 'search', true, isDarkMode),
                    ),
                    Expanded(
                      child: _buildNavItem(Icons.bar_chart, 'Analytics', 'analytics', false, isDarkMode),
                    ),
                    Expanded(
                      child: _buildNavItem(Icons.compare_arrows, 'Compare', 'compare', false, isDarkMode),
                    ),
                    Expanded(
                      child: _buildNavItem(Icons.history, 'History', 'history', false, isDarkMode),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Search Videos Section
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  // Use dynamic colors
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.search, color: Colors.white, size: 16),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Search Videos',
                              style: TextStyle(
                                color: Color(0xFFE53935),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Find and analyze YouTube content',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Keywords/URL Toggle
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => isKeywordsSelected = true),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                // Use dynamic colors
                                color: isKeywordsSelected ? (isDarkMode ? Color(0xFF3A4052) : Colors.grey[300]) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: isKeywordsSelected ? Color(0xFF4CAF50) : Colors.grey[600],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Keywords',
                                    style: TextStyle(
                                      color: isKeywordsSelected ? (isDarkMode ? Colors.white : Colors.black87) : Colors.grey[400],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => isKeywordsSelected = false),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                // Use dynamic colors
                                color: !isKeywordsSelected ? (isDarkMode ? Color(0xFF3A4052) : Colors.grey[300]) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.link,
                                    color: !isKeywordsSelected ? (isDarkMode ? Colors.white : Colors.black87) : Colors.grey[600],
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'URL',
                                    style: TextStyle(
                                      color: !isKeywordsSelected ? (isDarkMode ? Colors.white : Colors.black87) : Colors.grey[400],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Search Input
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        // Use dynamic colors
                        color: scaffoldColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade700),
                      ),
                      child: TextField(
                        controller: searchController,
                        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          hintText: isKeywordsSelected
                              ? 'Enter keywords to search videos...'
                              : 'Enter YouTube URL to analyze...',
                          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                          border: InputBorder.none,
                          suffixIcon: Icon(Icons.mic, color: Colors.grey[500], size: 20),
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Search Button
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _performSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFE53935),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Search',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // Ready to Analyze Section
              Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.play_arrow, color: Colors.white, size: 40),
                  ),

                  SizedBox(height: 16),

                  Text(
                    'Ready to Analyze Videos',
                    style: TextStyle(
                      color: Color(0xFFE53935),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    'Search for videos by keywords or paste\na YouTube URL to get started with AI-\npowered analytics',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 24),

                  // Feature Tags
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildFeatureTag('Smart Search', Color(0xFF4CAF50)),
                      _buildFeatureTag('AI Sentiment', Color(0xFFE91E63)),
                      _buildFeatureTag('Deep Analytics', Color(0xFF2196F3)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, String route, bool isActive, bool isDarkMode) {
    Color activeColor = Color(0xFF6366F1);

    if (label == 'History') {
      activeColor = Color(0xFFFF9800);
    }
    if (label == 'Search') {
      activeColor = Color(0xFFE53935);
    }
    if (label == 'Analytics') {
      activeColor = Color(0xFF6366F1);
    }
    if (label == 'Compare') {
      activeColor = Color(0xFF6366F1);
    }

    return GestureDetector(
      onTap: () {
        _handleNavigation(route);
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              // Use dynamic colors
              color: isDarkMode ? Color(0xFF1A1D29) : Colors.white,
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
                  MaterialPageRoute(builder: (context) => InsightTubeticsScreen()),
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
                  MaterialPageRoute(builder: (context) => InsightTubeticsScreen()),
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
                  MaterialPageRoute(builder: (context) => InsightTubeticsScreen()),
                      (route) => false,
                );
              },
            ),
          ),
        );
        break;
    }
  }

  Widget _buildFeatureTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
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
            ),
          ),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}