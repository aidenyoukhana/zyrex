//
//  Workout.swift
//  Zyrex
//
//  Created by Aiden Youkhana on 1/17/26.
//

import Foundation
import SwiftData

@Model
final class Workout {
    var id: UUID
    var name: String
    var workoutDescription: String
    var category: WorkoutCategory
    var difficulty: Difficulty
    var muscleGroups: [MuscleGroup]
    var mixamoAnimationName: String
    var durationSeconds: Int
    var reps: Int?
    var sets: Int?
    var restBetweenSetsSeconds: Int
    var instructions: [String]
    var thumbnailName: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        workoutDescription: String = "",
        category: WorkoutCategory = .strength,
        difficulty: Difficulty = .beginner,
        muscleGroups: [MuscleGroup] = [],
        mixamoAnimationName: String = "",
        durationSeconds: Int = 30,
        reps: Int? = nil,
        sets: Int? = nil,
        restBetweenSetsSeconds: Int = 30,
        instructions: [String] = [],
        thumbnailName: String? = nil
    ) {
        self.id = id
        self.name = name
        self.workoutDescription = workoutDescription
        self.category = category
        self.difficulty = difficulty
        self.muscleGroups = muscleGroups
        self.mixamoAnimationName = mixamoAnimationName
        self.durationSeconds = durationSeconds
        self.reps = reps
        self.sets = sets
        self.restBetweenSetsSeconds = restBetweenSetsSeconds
        self.instructions = instructions
        self.thumbnailName = thumbnailName
    }
}

// MARK: - Enums

enum WorkoutCategory: String, Codable, CaseIterable {
    case strength = "Strength"
    case cardio = "Cardio"
    case flexibility = "Flexibility"
    case hiit = "HIIT"
    case warmup = "Warm Up"
    case cooldown = "Cool Down"
    
    var icon: String {
        switch self {
        case .strength: return "dumbbell.fill"
        case .cardio: return "heart.fill"
        case .flexibility: return "figure.flexibility"
        case .hiit: return "bolt.fill"
        case .warmup: return "flame.fill"
        case .cooldown: return "snowflake"
        }
    }
}

enum Difficulty: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    var color: String {
        switch self {
        case .beginner: return "green"
        case .intermediate: return "orange"
        case .advanced: return "red"
        }
    }
}

enum MuscleGroup: String, Codable, CaseIterable {
    case chest = "Chest"
    case back = "Back"
    case shoulders = "Shoulders"
    case biceps = "Biceps"
    case triceps = "Triceps"
    case core = "Core"
    case glutes = "Glutes"
    case quadriceps = "Quadriceps"
    case hamstrings = "Hamstrings"
    case calves = "Calves"
    case fullBody = "Full Body"
}
