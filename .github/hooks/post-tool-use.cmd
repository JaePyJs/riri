@echo off
setlocal

REM Run ktlint formatting via Gradle wrapper to match CI config.
call "%~dp0\..\..\gradlew" ktlintFormat
set EXIT_CODE=%ERRORLEVEL%

if NOT "%EXIT_CODE%"=="0" (
  echo ktlintFormat failed with exit code %EXIT_CODE%.
)

exit /b %EXIT_CODE%
