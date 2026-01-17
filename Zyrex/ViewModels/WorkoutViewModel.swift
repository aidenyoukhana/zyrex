//
//  WorkoutViewModel.swift
//  Zyrex
//
//  Created by Aiden Youkhana on 1/17/26.
//

import Foundation
import SwiftData

@MainActor
@Observable
final class WorkoutViewModel {
    private let modelContext: ModelContext
    
    var workoutPlans: [WorkoutPlan] = []
    var workouts: [Workout] = []
    var selectedCategory: WorkoutCategory?
    var selectedDifficulty: Difficulty?
    var searchText: String = ""
    
    var filteredWorkoutPlans: [WorkoutPlan] {
        workoutPlans.filter { plan in
            let matchesCategory = selectedCategory == nil || plan.category == selectedCategory
            let matchesDifficulty = selectedDifficulty == nil || plan.difficulty == selectedDifficulty
            let matchesSearch = searchText.isEmpty || plan.name.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesDifficulty && matchesSearch
        }
    }
    
    var filteredWorkouts: [Workout] {
        workouts.filter { workout in
            let matchesCategory = selectedCategory == nil || workout.category == selectedCategory
            let matchesDifficulty = selectedDifficulty == nil || workout.difficulty == selectedDifficulty
            let matchesSearch = searchText.isEmpty || workout.name.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesDifficulty && matchesSearch
        }
    }
    
    var favoriteWorkoutPlans: [WorkoutPlan] {
        workoutPlans.filter { $0.isFavorite }
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func loadData() {
        loadWorkoutPlans()
        loadWorkouts()
    }
    
    private func loadWorkoutPlans() {
        let descriptor = FetchDescriptor<WorkoutPlan>(
            sortBy: [SortDescriptor(\.name)]
        )
        workoutPlans = (try? modelContext.fetch(descriptor)) ?? []
        
        // Seed sample data if empty
        if workoutPlans.isEmpty {
            seedSampleData()
        }
    }
    
    private func loadWorkouts() {
        let descriptor = FetchDescriptor<Workout>(
            sortBy: [SortDescriptor(\.name)]
        )
        workouts = (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func toggleFavorite(_ workoutPlan: WorkoutPlan) {
        workoutPlan.isFavorite.toggle()
        try? modelContext.save()
    }
    
    func deleteWorkoutPlan(_ workoutPlan: WorkoutPlan) {
        modelContext.delete(workoutPlan)
        try? modelContext.save()
        loadWorkoutPlans()
    }
    
    func clearFilters() {
        selectedCategory = nil
        selectedDifficulty = nil
        searchText = ""
    }
    
    // MARK: - Sample Data
    
    private func seedSampleData() {
        let sampleWorkouts = [
            Workout(
                name: "Squats",
                workoutDescription: "A compound lower body workout targeting quads, glutes, and core.",
                category: .strength,
                difficulty: .beginner,
                muscleGroups: [.quadriceps, .glutes, .core],
                mixamoAnimationName: "Squat",
                durationSeconds: 45,
                reps: 12,
                sets: 3,
                instructions: ["Stand with feet shoulder-width apart", "Lower your body as if sitting back into a chair", "Keep your chest up and core engaged", "Push through your heels to stand"]
            ),
            Workout(
                name: "Push-ups",
                workoutDescription: "Classic upper body workout for chest, shoulders, and triceps.",
                category: .strength,
                difficulty: .beginner,
                muscleGroups: [.chest, .shoulders, .triceps],
                mixamoAnimationName: "Push Up",
                durationSeconds: 45,
                reps: 10,
                sets: 3,
                instructions: ["Start in a plank position", "Lower your chest to the ground", "Keep your core tight", "Push back up to starting position"]
            ),
            Workout(
                name: "Jumping Jacks",
                workoutDescription: "Full body cardio workout to elevate heart rate.",
                category: .cardio,
                difficulty: .beginner,
                muscleGroups: [.fullBody],
                mixamoAnimationName: "Jumping Jacks",
                durationSeconds: 60,
                instructions: ["Start standing with arms at sides", "Jump while spreading legs and raising arms", "Return to starting position", "Repeat at a steady pace"]
            ),
            Workout(
                name: "Lunges",
                workoutDescription: "Unilateral leg workout for balance and strength.",
                category: .strength,
                difficulty: .intermediate,
                muscleGroups: [.quadriceps, .glutes, .hamstrings],
                mixamoAnimationName: "Lunge",
                durationSeconds: 60,
                reps: 10,
                sets: 3,
                instructions: ["Step forward with one leg", "Lower until both knees are at 90 degrees", "Push back to starting position", "Alternate legs"]
            ),
            Workout(
                name: "Plank",
                workoutDescription: "Isometric core workout for stability and strength.",
                category: .strength,
                difficulty: .beginner,
                muscleGroups: [.core, .shoulders],
                mixamoAnimationName: "Plank",
                durationSeconds: 30,
                instructions: ["Start in a forearm plank position", "Keep your body in a straight line", "Engage your core", "Hold the position"]
            ),
            Workout(
                name: "Burpees",
                workoutDescription: "High-intensity full body workout.",
                category: .hiit,
                difficulty: .advanced,
                muscleGroups: [.fullBody],
                mixamoAnimationName: "Burpee",
                durationSeconds: 45,
                reps: 10,
                sets: 3,
                instructions: ["Start standing", "Drop into a squat and place hands on floor", "Jump feet back to plank", "Do a push-up, jump feet forward, then jump up"]
            )
        ]
        
        for workout in sampleWorkouts {
            modelContext.insert(workout)
        }
        
        let sampleWorkoutPlans = [
            WorkoutPlan(
                name: "Quick Morning Stretch",
                planDescription: "Start your day right with this energizing routine.",
                category: .warmup,
                difficulty: .beginner,
                workouts: Array(sampleWorkouts.prefix(3)),
                estimatedDurationMinutes: 15
            ),
            WorkoutPlan(
                name: "Full Body Burn",
                planDescription: "A complete plan hitting all major muscle groups.",
                category: .strength,
                difficulty: .intermediate,
                workouts: sampleWorkouts,
                estimatedDurationMinutes: 30
            ),
            WorkoutPlan(
                name: "HIIT Blast",
                planDescription: "High intensity intervals for maximum calorie burn.",
                category: .hiit,
                difficulty: .advanced,
                workouts: Array(sampleWorkouts.suffix(3)),
                estimatedDurationMinutes: 20
            )
        ]
        
        for plan in sampleWorkoutPlans {
            modelContext.insert(plan)
        }
        
        try? modelContext.save()
        loadWorkoutPlans()
        loadWorkouts()
    }
}
