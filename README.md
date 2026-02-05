# InsightTube 🚀

**InsightTube** is an advanced AI-powered YouTube analytics application built with Flutter. It provides content creators and marketers with deep insights into video performance, audience sentiment, and competitive analysis.

## ✨ Key Features

- **📊 Comprehensive Analytics**: View detailed metrics like views, likes, comments, and engagement rates.
- **😊 AI Sentiment Analysis**: Automatically analyzes video comments to determine audience sentiment (Positive, Neutral, Negative) using advanced NLP.
- **🆚 Video Comparison**: Compare two videos side-by-side to understand performance differences visually.
- **🔍 Smart Search**:
    - **Real-time Suggestions**: Optimized for both Web (CORS proxy) and Mobile.
    - **Voice Search**: Hands-free searching with integrated speech-to-text.
- **zz History**: Automatically saves your analysis history for quick access.
- **🎨 Premium UI**: A modern, dark-themed, glassmorphism-inspired interface with smooth animations.

## 🛠️ Tech Stack

- **Framework**: Flutter & Dart
- **APIs**: YouTube Data API v3, Google Suggest API
- **State Management**: `setState` & `FutureBuilder` (Optimized for performance)
- **Key Packages**:
    - `http` (API Networking)
    - `fl_chart` (Data Visualization)
    - `shared_preferences` (Local Storage)
    - `speech_to_text` (Voice Recognition)
    - `permission_handler` (Native Permissions)

## 📱 Getting Started

1.  Clone the repository.
2.  Run `flutter pub get` to install dependencies.
3.  Add your YouTube Data API key in `lib/core/secrets.dart`.
4.  Run `flutter run` to start the app!

---
*Built with ❤️ using Flutter*
