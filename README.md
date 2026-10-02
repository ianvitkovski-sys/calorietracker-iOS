# CalorieTracker вЂ” iOS Calorie Tracking App

AI-powered food detection and nutritional tracking for iOS.

## Quick Start


### Option C: Cloud Build (No Mac Required)

You can build the app on GitHub's macOS runners:

1. Fork this repository on GitHub
2. Go to Actions tab → select "Build iOS App" workflow
3. Click "Run workflow" → choose branch
4. Wait ~15-20 minutes for the build to complete
5. Download the artifacts (CalorieTracker-simulator-app and CalorieTracker-device-app)
6. Install using [AltStore](https://altstore.io/) or [Sideloadly](https://sideloadly.io/)

Note: Device installation requires an Apple Developer account for code signing.

### Prerequisites
- macOS 14.0+ with Xcode 15.4+
- iOS 17.0+ deployment target

### Build Instructions

**Option A: Using xcodegen (Recommended)**

```bash
# Install xcodegen
brew install xcodegen

# Generate Xcode project
xcodegen

# Open and build
open CalorieTracker.xcodeproj
```

**Option B: Manual Xcode Setup**

1. Create a new iOS App project in Xcode
2. Add all `.swift` files from `CalorieTracker/` folder to your project
3. Set the bundle identifier to `com.kilocodes.CalorieTracker`
4. Add `Info.plist` and `Assets.xcassets` from this project
5. Build and run

### CoreML Model Integration

The app uses a CoreML model named `FoodDetector` for food detection:

1. Download the Food-101 model or train a custom one
2. Convert to CoreML format: `coremlcompiler compile FoodDetector.mlmodel`
3. Add `FoodDetector.mlmodel` to your Xcode project in the `CalorieTracker/Models/` folder
4. Xcode will auto-generate the `FoodDetector` Swift class

In debug mode, the app uses mock detection with sample data.

### USDA API Key (Optional)

For foods not in the local database, the app falls back to the USDA FoodData Central API:

1. Get a free API key at https://fdc.nal.usda.gov/api-key-signup.html
2. Add the key to your Xcode scheme's environment variables:
   - Name: `USDA_API_KEY`
   - Value: `your_api_key_here`

## Project Structure

```
CalorieTracker/
в”њв”Ђв”Ђ CalorieTrackerApp.swift          # App entry point
в”њв”Ђв”Ђ Info.plist                       # App configuration
в”њв”Ђв”Ђ Assets.xcassets/                 # App icons and images
в”њв”Ђв”Ђ LaunchScreen.storyboard          # Launch screen
в”њв”Ђв”Ђ Models/                          # SwiftData entities
в”‚   в”њв”Ђв”Ђ User.swift
в”‚   в”њв”Ђв”Ђ MealLog.swift
в”‚   в”њв”Ђв”Ђ FoodItemInMeal.swift
в”‚   в”њв”Ђв”Ђ FoodDatabaseEntry.swift
в”‚   в”њв”Ђв”Ђ FoodNutritionInfo.swift
в”‚   в”њв”Ђв”Ђ DetectedFood.swift
в”‚   в”њв”Ђв”Ђ WeightEstimate.swift
в”‚   в””в”Ђв”Ђ FoodDetector.swift            # CoreML model stub
в”њв”Ђв”Ђ ViewModels/                      # MVVM view models
в”њв”Ђв”Ђ Services/                        # Business logic & data services
в”њв”Ђв”Ђ Data/                            # Persistence & navigation
в”њв”Ђв”Ђ Views/
в”‚   в”њв”Ђв”Ђ RootView.swift               # Tab-based root
в”‚   в”њв”Ђв”Ђ Dashboard/                    # Daily summary views
в”‚   в”њв”Ђв”Ђ Diary/                       # Meal history views
в”‚   в”њв”Ђв”Ђ Camera/                      # Photo capture & analysis
в”‚   в”њв”Ђв”Ђ Insights/                    # Analytics & trends
в”‚   в”њв”Ђв”Ђ Profile/                     # User profile & settings
в”‚   в””в”Ђв”Ђ LaunchScreenView.swift
в””в”Ђв”Ђ Utils/
    в”њв”Ђв”Ђ Extensions/                  # Swift extensions
    в”њв”Ђв”Ђ Enums/                       # App enums
    в”њв”Ђв”Ђ Constants/                   # Constants & mappings
    в”њв”Ђв”Ђ Protocols/                   # Service protocols
    в”њв”Ђв”Ђ Config/                      # Build configurations
    в””в”Ђв”Ђ Debug/                       # Preview and mock data
```

## Architecture

- **Pattern**: MVVM + Clean Architecture
- **State Management**: SwiftData (iOS 17+) with ObservableObject ViewModels
- **Image Processing**: Vision Framework + CoreML (on-device, privacy-preserving)
- **Nutritional Data**: Pre-bundled USDA FoodData Central + API fallback
- **Weight Estimation**: Multi-modal (depth, reference objects, heuristics, user input)

## Key Features

- **AI Food Detection**: Upload photos to detect food items and estimate weights
- **Nutrition Breakdown**: Calories, macros, and micronutrients
- **Weight Estimation**: Multi-modal estimation with confidence-weighted fusion
- **Daily Dashboard**: Progress tracking with charts and rings
- **Meal Diary**: Historical view with calendar navigation
- **Insights**: Weekly/monthly analytics
- **Offline Mode**: Core detection and nutrition lookup work offline

## Notes

- The app uses mock food detection in DEBUG mode for development without a CoreML model
- All image processing happens on-device вЂ” photos never leave the device
- Requires iOS 17.0+ due to SwiftData usage

