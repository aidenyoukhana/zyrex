# Zyrex 💪

A modern, contemporary workout app featuring **Maximoo** animated characters (powered by Mixamo) as your personal fitness guides and real-time pose detection to perfect your form.

![Simulator Screen Recording - iPhone 17 Pro Max - 2026-01-17 at 12 49 40](https://github.com/user-attachments/assets/2b63cced-29b6-41af-8f16-25d70654bc42)
<img width="250" alt="Simulator Screenshot - iPhone 17 Pro Max - 2026-01-17 at 12 47 42" src="https://github.com/user-attachments/assets/2851df5b-e042-48ec-8c34-d8277e5861db" />
<img width="250" alt="Simulator Screenshot - iPhone 17 Pro Max - 2026-01-17 at 13 02 04" src="https://github.com/user-attachments/assets/3c623c6d-ff71-4ddc-822f-0e37d0fc399c" />
<img width="250" alt="Simulator Screenshot - iPhone 17 Pro Max - 2026-01-17 at 13 01 57" src="https://github.com/user-attachments/assets/a209ab66-697c-4934-87ec-f33351876824" />



## ✨ Features

- **Maximoo Guides** — 3D animated characters demonstrate each exercise with style
- **Real-Time Pose Detection** — Powered by Google MediaPipe for accurate body tracking
- **Form Feedback** — Live corrections to ensure you're doing exercises safely and effectively
- **Workout Library** — Curated collection of exercises for all fitness levels
- **Progress Tracking** — Monitor your fitness journey over time
- **Achievements** — Unlock badges as you hit milestones

## 📱 App Tabs

| Tab | Description |
|-----|-------------|
| **Home** | Dashboard with greeting, streak, weekly progress, and suggested workouts |
| **Workout** | Browse workouts and exercises by category, difficulty, and muscle group |
| **Practice** | Camera-based practice with Maximoo demo + real-time pose detection |
| **Analysis** | Stats, charts, workout history, streaks, and achievements |
| **Settings** | Profile, goals, Maximoo character selection, notifications, and preferences |

## 🛠 Tech Stack

- **SwiftUI** — Modern declarative UI framework
- **SwiftData** — Persistent storage with `@Model` and `@MainActor`
- **AVFoundation** — Camera capture and processing
- **Google MediaPipe** — ML-powered pose estimation
- **SceneKit** — 3D Mixamo character animations
- **Charts** — Native SwiftUI charts for analytics

## 🏗 Architecture

Zyrex follows a strict **MVVM (Model-View-ViewModel)** pattern with SwiftData integration:

```
Zyrex/
├── Models/          # @Model SwiftData entities
│   ├── Workout.swift
│   ├── WorkoutPlan.swift
│   ├── WorkoutSession.swift
│   ├── UserProfile.swift
│   └── PoseData.swift
├── ViewModels/      # @MainActor @Observable view models
│   ├── HomeViewModel.swift
│   ├── WorkoutViewModel.swift
│   ├── PracticeViewModel.swift
│   ├── AnalysisViewModel.swift
│   └── SettingsViewModel.swift
├── Views/           # SwiftUI views
│   ├── MainTabView.swift
│   ├── Home/
│   ├── Workout/
│   ├── Practice/
│   ├── Analysis/
│   └── Settings/
└── Services/        # Camera, MediaPipe, etc.
```

### SwiftData Models
All data models use the `@Model` macro for automatic persistence:

```swift
@Model
final class WorkoutPlan {
    var name: String
    var workouts: [Workout]
    // ...
}
```

### ViewModels
ViewModels are marked with `@MainActor` and `@Observable` for thread-safe UI updates:

```swift
@MainActor
@Observable
final class WorkoutViewModel {
    private let modelContext: ModelContext
    var workouts: [Workout] = []
    // ...
}
```

### Views
Views observe their corresponding ViewModel and remain lightweight:

```swift
struct WorkoutView: View {
    @State private var viewModel: WorkoutViewModel
    // ...
}
```

## 🚀 Getting Started

1. Clone the repository
2. Open `Zyrex.xcodeproj` in Xcode
3. Build and run on a physical device (camera required for pose detection)

## 📱 Requirements

- iOS 17.0+
- Xcode 15.0+
- Physical device with camera for pose detection features

## 🎨 Design Philosophy

Zyrex combines fun and fitness — making workouts engaging through playful Maximoo characters while ensuring proper form with cutting-edge pose detection technology.

---

*Get fit. Have fun. Let Maximoo show you the way.* 🐄
