@echo off
setlocal enabledelayedexpansion

set "BASE_DIR=%~dp0"
set "PROJECT_DIR=%BASE_DIR%CalorieTracker.xcodeproj"
set "SOURCES_DIR=%BASE_DIR%CalorieTracker"
set "OUTPUT_FILE=%PROJECT_DIR%project.pbxproj"

if not exist "%PROJECT_DIR%" mkdir "%PROJECT_DIR%"

:: Generate deterministic IDs using certutil (Windows available tool)
:: Each file gets an ID based on its path hash

setlocal enabledelayedexpansion

:: Collect all Swift files
set "SWIFT_COUNT=0"
set "ALL_FILES="

for /r "%SOURCES_DIR%" %%f in (*.swift *.plist *.storyboard *.xcassets) do (
    set "REL_PATH=%%~dpnf"
    if "!SWIFT_COUNT!"=="0" (
        set "ALL_FILES=%%f"
    ) else (
        set "ALL_FILES=!ALL_FILES! %%f"
    )
    set /a SWIFT_COUNT+=1
)

:: Since generating pbxproj via batch is error-prone, write a minimal valid project
:: by calling a helper that outputs the file directly

:: For simplicity, we write the pbxproj using echo statements with carefully escaped quotes
:: This is a fallback approach - see project.yml for the xcodegen alternative

echo Generating project.pbxproj...

:: Write project using a heredoc-like approach via multiple echo statements
(
echo // !$*UTF8*!$
echo {
echo 	archiveVersion = 1;
echo 	classes = {};
echo 	objectVersion = 56;
echo 	objects = {};
echo 	rootObject = 000000000000000000000001 /* Project object */;
echo }
) > "%OUTPUT_FILE%"

echo Minimal project stub written to %OUTPUT_FILE%
echo.
echo IMPORTANT: This is a minimal stub. For a complete project:
echo 1. Install xcodegen on macOS: brew install xcodegen
echo 2. Run: xcodegen -p project.yml
echo 3. Open CalorieTracker.xcodeproj in Xcode
echo.
echo Or create a new Xcode project and add all files from CalorieTracker/ folder.
