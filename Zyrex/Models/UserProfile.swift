//
//  UserProfile.swift
//  Zyrex
//
//  Created by Aiden Youkhana on 1/17/26.
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var name: String
    var avatarName: String?
    var fitnessLevel: Difficulty
    var weeklyGoalMinutes: Int
    var dailyReminderEnabled: Bool
    var reminderTime: Date?
    var soundEnabled: Bool
    var hapticsEnabled: Bool
    var selectedMaximooCharacter: String
    var streakCount: Int
    var lastWorkoutDate: Date?
    var totalWorkoutsCompleted: Int
    var totalMinutesExercised: Int
    var joinedAt: Date
    
    init(
        id: UUID = UUID(),
        name: String = "Athlete",
        avatarName: String? = nil,
        fitnessLevel: Difficulty = .beginner,
        weeklyGoalMinutes: Int = 150,
        dailyReminderEnabled: Bool = true,
        reminderTime: Date? = nil,
        soundEnabled: Bool = true,
        hapticsEnabled: Bool = true,
        selectedMaximooCharacter: String = "default",
        streakCount: Int = 0,
        lastWorkoutDate: Date? = nil,
        totalWorkoutsCompleted: Int = 0,
        totalMinutesExercised: Int = 0,
        joinedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.avatarName = avatarName
        self.fitnessLevel = fitnessLevel
        self.weeklyGoalMinutes = weeklyGoalMinutes
        self.dailyReminderEnabled = dailyReminderEnabled
        self.reminderTime = reminderTime
        self.soundEnabled = soundEnabled
        self.hapticsEnabled = hapticsEnabled
        self.selectedMaximooCharacter = selectedMaximooCharacter
        self.streakCount = streakCount
        self.lastWorkoutDate = lastWorkoutDate
        self.totalWorkoutsCompleted = totalWorkoutsCompleted
        self.totalMinutesExercised = totalMinutesExercised
        self.joinedAt = joinedAt
    }
}
