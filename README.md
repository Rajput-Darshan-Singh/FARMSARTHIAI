<!-- @format -->

FARM SARTHI AI — README
Project Overview

Name: FARM SARTHI AI — Mobile App + Plant Disease Prediction Model

Purpose: A cross-platform Flutter mobile app for farmers that uses a trained rice disease detection model (.h5) to identify rice leaf diseases from images and show remedies.

Highlights

Mobile App: Flutter project located in lib/ + platform folders (android/, ios/, etc.). Includes camera support, localization, and clean UI.

AI Model: AIML/rice_model_final.h5 + prediction script AIML/predict.py + metadata file AIML/data/diseases_data.json.

Cross-Platform: Works on Android, iOS, Web, Windows, macOS, Linux.

Repository Structure
lib/ → Flutter app source (UI, screens, providers)
android/ ios/ web/ → Platform-specific files
AIML/
├── predict.py → Run predictions using Keras model
├── requirements.txt → Python dependencies
├── rice_model_final.h5
└── data/
└── diseases_data.json
assets/ → Images + language .arb files
test/ → Flutter widget tests

Features

📸 Capture or upload a rice leaf image

🤖 Instant disease prediction using Keras model

📘 Symptoms, disease details, remedies

🌐 Multi-language UI from assets/lang/

Quick Setup

1. Run AI Model (Python)
   pip install -r requirements.txt
   python predict.py

2. Run Flutter App
   flutter pub get
   flutter run

3. Prerequisites

Flutter: Install Flutter SDK + Android SDK / Xcode

Python: Python 3.8+

Tools: Git, VS Code / Android Studio, Internet

2. Running the Flutter App
   flutter pub get
   flutter run -d <device-id>

# Build release APK

flutter build apk --release

For iOS, open ios/Runner.xcworkspace in Xcode and run.
