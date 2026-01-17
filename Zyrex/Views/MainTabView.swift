//
//  MainTabView.swift
//  Zyrex
//
//  Created by Aiden Youkhana on 1/17/26.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: Tab = .home
    
    enum Tab: String, CaseIterable {
        case home = "Home"
        case workouts = "Workouts"
        case practice = "Practice"
        case settings = "Settings"
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .workouts: return "dumbbell.fill"
            case .practice: return "camera.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: HomeViewModel(modelContext: modelContext))
                .tabItem {
                    Label(Tab.home.rawValue, systemImage: Tab.home.icon)
                }
                .tag(Tab.home)
            
            WorkoutView(viewModel: WorkoutViewModel(modelContext: modelContext))
                .tabItem {
                    Label(Tab.workouts.rawValue, systemImage: Tab.workouts.icon)
                }
                .tag(Tab.workouts)
            
            PracticeView(viewModel: PracticeViewModel(modelContext: modelContext))
                .tabItem {
                    Label(Tab.practice.rawValue, systemImage: Tab.practice.icon)
                }
                .tag(Tab.practice)
            
            SettingsView(viewModel: SettingsViewModel(modelContext: modelContext))
                .tabItem {
                    Label(Tab.settings.rawValue, systemImage: Tab.settings.icon)
                }
                .tag(Tab.settings)
        }
        .tint(.orange)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Workout.self, WorkoutPlan.self, WorkoutSession.self, UserProfile.self], inMemory: true)
}
