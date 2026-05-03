# Kinetix Habit Tracker

Kinetix is a modern, sleek habit-tracking application built with Flutter and Firebase. It helps users stay organized by managing tasks, tracking progress through a calendar, and visualizing habits with clean, interactive UI components.

## 🚀 Features

- **Authentication:** Secure login and registration powered by Firebase Authentication.
- **Task Management:** Create, edit, and delete tasks with categories, priorities, and descriptions.
- **Calendar Integration:** Interactive calendar view using `table_calendar` to track daily tasks and streaks.
- **Radial Hero Animations:** Seamless, visually appealing transitions when creating new tasks.
- **Statistics:** Track your performance and habit consistency over time.
- **Archiving:** Keep your main dashboard clean by archiving completed or old tasks.
- **Modern UI:** Built with Google Fonts and custom-themed widgets for a premium look and feel.

## 🛠️ Tech Stack

- **Frontend:** [Flutter](https://flutter.dev/) (Dart)
- **Backend:** [Firebase](https://firebase.google.com/)
  - **Auth:** Firebase Authentication
  - **Database:** Cloud Firestore
- **State Management:** Provider / Stream-based architecture
- **UI Components:**
  - `google_fonts` for typography
  - `table_calendar` for schedule management
  - Custom Radial Hero animations for smooth transitions

## 📦 Project Structure

```text
lib/
├── data/       # Static/Dummy data
├── models/     # Data models (TaskModel, etc.)
├── screens/    # App screens (Auth, Main, Calendar, etc.)
├── services/   # Firebase and Business logic (AuthService, TaskService)
├── theme/      # App styling and colors
├── utils/      # Helpers and formatters
└── widgets/    # Reusable UI components
```

## ⚙️ Getting Started

### Prerequisites

- Flutter SDK (latest version recommended)
- Firebase project setup
- Android Studio / VS Code with Flutter extensions

### Setup Instructions

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd habit_tracker
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration:**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/).
   - Add Android/iOS apps to your Firebase project.
   - Download the `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS).
   - Place `google-services.json` in `android/app/`.
   - Place `GoogleService-Info.plist` in `ios/Runner/`.
   - Ensure the `firebase_options.dart` in `lib/` is correctly configured for your project.

4. **Run the app:**
   ```bash
   flutter run
   ```

## ✨ Special Animations

### Radial Hero Transition
The app features a custom **Radial Hero Animation** when navigating from the Calendar to the New Task screen. 
- **Implementation:** Uses a `flightShuttleBuilder` with a `CustomClipper` (`_CircleClipper`).
- **Effect:** The destination screen expands radially from the center of the action button, providing a fluid "ripple" transition rather than a basic slide.

---

Built with ❤️ using Flutter.
