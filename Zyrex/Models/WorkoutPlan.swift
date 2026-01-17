//
//  WorkoutPlan.swift
//  Zyrex
//
//  Created by Aiden Youkhana on 1/17/26.
//

import Foundation
import SwiftData

@Model
final class WorkoutPlan {
    var id: UUID
    var name: String
    var planDescription: String
    var category: WorkoutCategory
    var difficulty: Difficulty
    var workouts: [Workout]
    var estimatedDurationMinutes: Int
    var thumbnailName: String?
    var isFavorite: Bool
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        planDescription: String = "",
        category: WorkoutCategory = .strength,
        difficulty: Difficulty = .beginner,
        workouts: [Workout] = [],
        estimatedDurationMinutes: Int = 30,
        thumbnailName: String? = nil,
        isFavorite: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.planDescription = planDescription
        self.category = category
        self.difficulty = difficulty
        self.workouts = workouts
        self.estimatedDurationMinutes = estimatedDurationMinutes
        self.thumbnailName = thumbnailName
        self.isFavorite = isFavorite
        self.createdAt = createdAt
    }
}
