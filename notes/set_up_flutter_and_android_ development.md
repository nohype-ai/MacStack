# Set Up Flutter and Android Development

* My Mac Stack config already:
  - Installs "fvm"
  - Installs the "android-commandlinetools"
  - Sets Android SDK environment variables (ANDROID_HOME and path in PATH)
* To build an android app I still have to manually (example commands):
  - Install Flutter: `fvm install stable && fvm use stable`
  - Accept Android SDK Licenses: `sdkmanager --licenses`
  - Install Required SDK Components: `sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"`
  - Verify Setup: `fvm flutter doctor`
  - Build the Flutter Android App:
    - dev flavour: `fvm flutter build apk --flavor dev -t lib/main_dev.dart`
    - prod flavour: `fvm flutter build apk --flavor prod -t lib/main_prod.dart`