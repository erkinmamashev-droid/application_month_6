# flutter_application_6mouth

Quiz app with configurable question categories and difficulty, timed questions,
and a score summary after each quiz.

Quiz progress and results are managed with Cubit. Completed results are stored
locally with Hive and can be reviewed from the History tab.

The Settings tab lets you switch between light and a low-glare dark theme. The
selected appearance is saved locally and restored on the next launch.

Quiz categories and multiple-choice questions are loaded from
[Open Trivia DB](https://opentdb.com/) using Dio. An internet connection is
required to load categories and start a quiz.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
