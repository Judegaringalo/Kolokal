# KOLOKAL

KOLOKAL is a Flutter-based Filipino language learning game designed to help students learn and practice formal Filipino words that match commonly used slang or informal terms.

The app combines quiz-based learning with a creative writing activity, allowing users to answer vocabulary questions, unlock difficulty levels, track progress, and write a tula using formal Filipino words.

## Project Description

KOLOKAL, also presented as **Linggwistikong Laro**, is an educational mobile application focused on Filipino language learning. It introduces users to formal Filipino vocabulary by asking questions about the correct formal equivalent of slang, casual, or commonly used words.

The app is designed for students who want to improve their vocabulary, recognize the difference between informal and formal Filipino terms, and apply what they learned through a tula writing activity.

## Features

- Filipino language learning quiz
- Student information input
- Three quiz difficulty levels
- Locked and unlockable level progression
- Heart-based life system
- Score tracking
- Answer feedback
- Saved quiz progress
- Tula writing activity
- Auto-save draft for tula
- Word count display
- Save tula as an image
- Local data storage using Shared Preferences
- Custom fonts and visual assets

## Main Modules

### Onboarding Screen

The onboarding screen introduces users to KOLOKAL and explains the purpose of the app. Users can start the learning experience from this screen.

### Student Information

Before starting, users are asked to enter their name and section. This information is saved locally and used inside the app.

### Levels Page

The levels page shows the available learning activities:

- **Madali** - beginner-level quiz
- **Katamtaman** - medium-level quiz
- **Mahirap** - advanced-level quiz
- **Tula** - creative writing activity

The higher quiz levels are locked until the previous level is completed.

### Quiz Page

The quiz page presents Filipino vocabulary questions. Users select an answer from multiple choices and receive feedback based on whether their answer is correct.

The quiz system includes:

- Multiple-choice questions
- Correct answer checking
- Explanation after answering
- Heart/life deduction for wrong answers
- Saved progress per level
- Final score display

### Tula Writing Page

The tula writing page allows users to write a poem using the formal words they learned from the quiz.

The tula module includes:

- Text input for writing
- Auto-save draft
- Word count tracking
- Writing tips
- Save as image feature

## Tech Stack

- **Framework:** Flutter
- **Language:** Dart
- **Local Storage:** Shared Preferences
- **Image Export:** Screenshot
- **Gallery Saving:** Image Gallery Saver Plus
- **Permissions:** Permission Handler
- **Fonts:** Poppins and Marker

## Main Dependencies

The project uses the following Flutter packages:

- `cupertino_icons`
- `shared_preferences`
- `intl`
- `path_provider`
- `permission_handler`
- `screenshot`
- `image_gallery_saver_plus`

## Project Structure

```txt
lib/
├── app_styles.dart
├── levels_page.dart
├── main.dart
├── quiz_page.dart
├── student_info.dart
└── tula.dart
```

## Getting Started

Follow these steps to run the project locally.

### Prerequisites

Make sure you have the following installed:

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- Android emulator or physical Android device
- Git

### Installation

Clone the repository:

```bash
git clone https://github.com/JudeGaringalo/Kolokal.git
```

Go to the project folder:

```bash
cd Kolokal
```

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

## Assets and Fonts

The project uses local assets and custom fonts inside the `assets/` directory.

```txt
assets/
├── fonts/
└── image and graphic assets
```

The app uses the following fonts:

- **Poppins**
- **Marker**

## App Flow

1. User opens the app.
2. The onboarding screen introduces KOLOKAL.
3. User enters their name and section.
4. User is redirected to the levels page.
5. User starts with the Madali quiz level.
6. Completing a level unlocks the next difficulty.
7. User can review their score and progress.
8. User can write a tula using formal Filipino words.
9. The tula draft is auto-saved and can be saved as an image.

## Local Storage

KOLOKAL uses `shared_preferences` to save user data and progress locally on the device.

Saved data may include:

- Student name
- Section
- Onboarding completion status
- Current hearts
- Locked/unlocked levels
- Quiz progress
- Quiz results
- Tula draft

## Future Improvements

Possible future improvements include:

- More vocabulary questions
- More difficulty levels
- Better result analytics
- Sound effects and feedback animations
- Teacher/admin review mode
- Exportable student results
- More writing activities aside from tula
- Filipino grammar lessons
- Leaderboard or classroom mode

## Developer

Maintained by:

- JudeGaringalo

## Purpose

This project was created for academic and educational purposes. It demonstrates mobile app development using Flutter while promoting Filipino language learning through interactive quizzes and creative writing.
