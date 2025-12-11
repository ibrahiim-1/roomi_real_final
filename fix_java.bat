@echo off
set JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.17.10-hotspot
set PATH=%JAVA_HOME%\bin;%PATH%
echo JAVA_HOME is now: %JAVA_HOME%
java -version
flutter clean
flutter pub get
flutter run
pause
