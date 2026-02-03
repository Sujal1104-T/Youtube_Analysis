class SentimentService {
  // Simplified AFINN-165 word list for local analysis
  static final Map<String, int> _wordScores = {
    'amazing': 4, 'awesome': 4, 'excellent': 4, 'good': 3, 'great': 3,
    'love': 3, 'wonderful': 4, 'best': 3, 'fantastic': 4, 'happy': 3,
    'cool': 1, 'nice': 2, 'better': 2, 'fun': 2, 'beautiful': 3,
    'glad': 3, 'excited': 3, 'perfect': 3, 'brilliant': 4, 'win': 4,
    'clean': 2, 'fresh': 1, 'sweet': 2, 'super': 3, 'like': 2,
    
    'bad': -3, 'terrible': -4, 'awful': -4, 'hate': -4, 'worst': -4,
    'horrible': -4, 'boring': -2, 'sad': -2, 'wrong': -2, 'stupid': -4,
    'waste': -3, 'broken': -2, 'annoying': -2, 'ugly': -3, 'mad': -3,
    'cheat': -4, 'fake': -3, 'scam': -4, 'poor': -2, 'dirty': -2,
    'disappointed': -2, 'fail': -4, 'nasty': -3, 'sick': -2, 'hell': -4,
    
    // Tech specific
    'slow': -2, 'fast': 2, 'bug': -2, 'crash': -3, 'lag': -2,
    'smooth': 2, 'error': -2, 'fix': 1, 'problem': -2, 'issue': -2,
    'useful': 2, 'useless': -2, 'informative': 2, 'helpful': 2
  };

  Map<String, dynamic> analyzeComments(List<String> comments) {
    if (comments.isEmpty) {
      return {
        'score': 0.0,
        'overall_sentiment': 'Neutral',
        'total_comments': 0
      };
    }

    int totalScore = 0;
    int positiveCount = 0;
    int negativeCount = 0;

    for (var comment in comments) {
      int commentScore = _analyzeText(comment);
      totalScore += commentScore;
      
      if (commentScore > 0) positiveCount++;
      if (commentScore < 0) negativeCount++;
    }

    double averageScore = totalScore / comments.length;
    String overallSentiment = 'Neutral';
    if (averageScore > 0.5) overallSentiment = 'Positive';
    if (averageScore < -0.5) overallSentiment = 'Negative';

    // Calculate score 0-100 logic for UI compatibility
    // Map -5 to 5 range to 0-100 roughly
    double uiScore = ((averageScore + 5) / 10) * 100;
    uiScore = uiScore.clamp(0.0, 100.0);

    return {
      'score': double.parse(uiScore.toStringAsFixed(1)),
      'overall_sentiment': overallSentiment,
      'total_comments': comments.length,
      'raw_score': totalScore,
      'positive_count': positiveCount,
      'negative_count': negativeCount,
    };
  }

  int _analyzeText(String text) {
    int score = 0;
    List<String> words = text.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').split(' ');
    
    for (var word in words) {
      if (_wordScores.containsKey(word)) {
        score += _wordScores[word]!;
      }
    }
    return score;
  }
}
