@echo off
title TokenX - Build Android APK
echo ========================================================
echo         TokenX - KRCT Hostel Mess Mobile App
echo                 Android APK Builder
echo ========================================================
echo.

where flutter >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Flutter SDK is not detected in your PATH environment.
    echo.
    echo To build the APK locally on this computer:
    echo 1. Install Flutter SDK: https://docs.flutter.dev/get-started/install/windows
    echo    Or run: winget install Flutter.Flutter
    echo 2. Install Android Studio with Android SDK Command-line Tools:
    echo    https://developer.android.com/studio
    echo 3. Add Flutter and Android SDK to your System PATH.
    echo.
    echo Alternatively, use GitHub Actions:
    echo Push this folder to a GitHub repository, and GitHub will automatically
    echo build and provide the downloadable .apk file in the 'Actions' tab!
    echo ========================================================
    pause
    exit /b 1
)

echo [1/3] Getting Flutter dependencies...
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to get dependencies.
    pause
    exit /b 1
)

echo [2/3] Running tests...
call flutter test
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] Some tests failed or were skipped. Continuing build...
)

echo [3/3] Compiling Release APK...
call flutter build apk --release --no-tree-shake-icons
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] APK compilation failed. Please verify Android SDK licenses using: flutter doctor --android-licenses
    pause
    exit /b 1
)

echo.
echo ========================================================
echo [SUCCESS] APK compiled successfully!
echo Location: build\app\outputs\flutter-apk\app-release.apk
echo ========================================================
pause
