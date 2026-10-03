# CalorieTracker

AI-assisted calorie tracking for iOS. Photograph a meal, detect the food items, estimate portion
weights, and log the nutritional breakdown.

> **New here? Read [GET_ON_IPHONE.md](GET_ON_IPHONE.md)** — it has the step-by-step path for
> building this on Windows without a Mac and installing it on your iPhone.

## Requirements

- iOS 17.0 or later (SwiftData)
- Swift 5.9
- Built with Xcode 16.x

## Building

The Xcode project is generated from `project.yml` by
[XcodeGen](https://github.com/yonaskolb/XcodeGen), so it is not checked into git.

```bash
brew install xcodegen
xcodegen generate
open CalorieTracker.xcodeproj
```

`xcodegen generate` must be re-run whenever files are added or removed.

## Architecture

| Layer | Contents |
|---|---|
| `Models/` | SwiftData entities and value types |
| `ViewModels/` | `@MainActor` `ObservableObject` view models |
| `Services/` | Camera, CoreML detection, weight estimation, nutrition lookup |
| `Data/` | `AppContainer` dependency graph, SwiftData stack |
| `Utils/` | Extensions, enums, constants, protocols, previews |

- **Pattern** — MVVM with a lightweight dependency container (`AppContainer.shared`)
- **State** — SwiftData (`@Model`) with `ObservableObject` view models
- **Detection** — Vision framework + CoreML, on-device
- **Nutrition** — bundled seed data with an optional USDA FoodData Central fallback
- **Weight estimation** — confidence-weighted fusion of plate scale, reference objects, and heuristics

## Current build status

`FoodDetector.mlmodel` is **not** bundled yet, so `FoodDetectionService` reports mock detections in
both `DEBUG` and `Release`. Every screen, flow, and nutrition calculation is functional; only the
image recognition is stubbed. To add real detection, drop a compiled `FoodDetector.mlmodel` into
`CalorieTracker/Models/` and implement `loadCoreMLModel()` and `extractDetectedFoods(from:imageSize:)`
in `Services/FoodDetectionService.swift`, where the Vision request is already sketched.

## USDA API key (optional)

Only needed for foods missing from the bundled seed data. Get a free key at
<https://fdc.nal.usda.gov/api-key-signup.html>, then set `USDA_API_KEY` in `project.yml` or as a CI
secret before building. Never commit the key.

## Project layout

```
CalorieTracker/
|-- .github/workflows/build.yml    # CI: unsigned IPA for Sideloadly
|-- project.yml                    # XcodeGen definition
|-- GET_ON_IPHONE.md               # iPhone install instructions
|-- CalorieTracker/
|   |-- CalorieTrackerApp.swift    # @main entry point
|   |-- RootView.swift             # splash, tab bar, per-tab NavigationStack
|   |-- Info.plist
|   |-- LaunchScreen.storyboard
|   |-- Assets.xcassets/
|   |-- Config/                    # xcconfig files
|   |-- Models/                    # SwiftData entities
|   |-- ViewModels/
|   |-- Services/
|   |-- Data/
|   `-- Utils/
```