//
//  WorkoutSession.swift
//  Zyrex
//
//  Created by Aiden Youkhana on 1/17/26.
//

import Foundation
import SwiftData

@Model
final class WorkoutSession {
    var id: UUID
    var workoutPlan: WorkoutPlan?
    var startedAt: Date
    var completedAt: Date?
    var totalDurationSeconds: Int
    var workoutsCompleted: Int
    var totalWorkouts: Int
    var averageFormScore: Double
    var caloriesBurned: Int
    var notes: String?
    
    var isCompleted: Bool {
        completedAt != nil
    }
    
    init(
        id: UUID = UUID(),
        workoutPlan: WorkoutPlan? = nil,
        startedAt: Date = .now,
        completedAt: Date? = nil,
        totalDurationSeconds: Int = 0,
        workoutsCompleted: Int = 0,
        totalWorkouts: Int = 0,
        averageFormScore: Double = 0.0,
        caloriesBurned: Int = 0,
        notes: String? = nil
    ) {
        self.id = id
        self.workoutPlan = workoutPlan
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.totalDurationSeconds = totalDurationSeconds
        self.workoutsCompleted = workoutsCompleted
        self.totalWorkouts = totalWorkouts
        self.averageFormScore = averageFormScore
        self.caloriesBurned = caloriesBurned
        self.notes = notes
    }
}
