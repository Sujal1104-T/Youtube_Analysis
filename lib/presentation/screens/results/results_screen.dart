import 'package:flutter/material.dart';
import '../analytics/analytics_screen.dart';

class ResultsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> videos;
  final VoidCallback? onBackToSearch;

  const ResultsScreen({
    Key? key,
    required this.videos,
    this.onBackToSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1D29),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1D29),
        elevation: 0,
        title: Text(
          'Search Results',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (onBackToSearch != null) {
              onBackToSearch!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: videos.isEmpty
          ? Center(
        child: Text(
          'No videos found for this search.',
          style: TextStyle(color: Colors.grey[400]),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          final thumbnail = video['thumbnail'];
          final title = video['title'];
          final channelTitle = video['channelTitle'];
          final videoId = video['id'];

          return GestureDetector(
            onTap: () {
              // Navigate to the Analytics screen with the selected video's ID
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnalyticsScreen(
                    videoId: videoId,
                    onBackToSearch: onBackToSearch,
                  ),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF2A2F3E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      thumbnail,
                      width: 100,
                      height: 75,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          channelTitle,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
