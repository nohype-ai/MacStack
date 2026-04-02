# Set Up Flutter and Android Development

Flutter/Android are not anymore in the example stack (in [stack/](../stack/)) because I neither need nor like them. Also, Flutter requires Cocoapods, which is ridiculous.

To add them back into the stack in a minimal working way, follow the steps below.

## 1. Brewfile

Put something like this into your [Brewfile](../stack/Brewfile):
```ruby
# Flutter development (iOS and Android)
# core issue: fvm is broken: latest fvm could under some circumstances NOT be installed via brew at all, because it expected to be bundled with a dart version with which it is not bundled 🤡
# alternative to explore: mise https://mise.jdx.dev/dev-tools/
tap "leoafarias/fvm" # Required for installing fvm#
brew "fvm" # flutter version manager
brew "cocoapods" # necessary for building iOS apps with Flutter
cask "android-commandlinetools" # for Android development
```

## 2. .zshrc

Put this back into the [custom_zshrc_content.sh](../stack/custom_zshrc_content.sh) so it gets sourced in .zshrc:
```bash
# Setup Android SDK
export ANDROID_HOME=/opt/homebrew/share/android-commandlinetools
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools
```

## 3. Manual One-Time Setup

Do the following (example commands):
- Install Flutter: `fvm install stable && fvm use stable`
- Accept Android SDK Licenses: `sdkmanager --licenses`
- Install Required SDK Components: `sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"`
- Verify Setup: `fvm flutter doctor`

## 4. Build a Flutter Android App

- dev flavour: `fvm flutter build apk --flavor dev -t lib/main_dev.dart`
- prod flavour: `fvm flutter build apk --flavor prod -t lib/main_prod.dart`
