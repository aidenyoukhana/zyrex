//
//  SettingsViewModel.swift
//  Zyrex
//
//  Created by Aiden Youkhana on 1/17/26.
//

import Foundation
import SwiftData

@MainActor
@Observable
final class SettingsViewModel {
    private let modelContext: ModelContext
    
    var userProfile: UserProfile?
    
    // Profile settings
    var userName: String = ""
    var fitnessLevel: Difficulty = .beginner
    var weeklyGoalMinutes: Int = 150
    
    // Notification settings
    var dailyReminderEnabled: Bool = true
    var reminderTime: Date = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
    
    // App settings
    var soundEnabled: Bool = true
    var hapticsEnabled: Bool = true
    var selectedMaximooCharacter: String = "default"
    
    // Available Maximoo characters
    let maximooCharacters = [
        MaximooCharacter(id: "default", name: "Classic Maximoo", preview: "maximoo_default"),
        MaximooCharacter(id: "sporty", name: "Sporty Maximoo", preview: "maximoo_sporty"),
        MaximooCharacter(id: "zen", name: "Zen Maximoo", preview: "maximoo_zen"),
        MaximooCharacter(id: "power", name: "Power Maximoo", preview: "maximoo_power")
    ]
    
    // Stats (read-only display)
    var totalWorkoutsCompleted: Int = 0
    var totalMinutesExercised: Int = 0
    var memberSince: Date = Date()
    
    var hasUnsavedChanges: Bool {
        guard let profile = userProfile else { return false }
        return userName != profile.name ||
               fitnessLevel != profile.fitnessLevel ||
               weeklyGoalMinutes != profile.weeklyGoalMinutes ||
               dailyReminderEnabled != profile.dailyReminderEnabled ||
               soundEnabled != profile.soundEnabled ||
               hapticsEnabled != profile.hapticsEnabled ||
               selectedMaximooCharacter != profile.selectedMaximooCharacter
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func loadData() {
        loadUserProfile()
    }
    
    private func loadUserProfile() {
        let descriptor = FetchDescriptor<UserProfile>()
        userProfile = try? modelContext.fetch(descriptor).first
        
        if userProfile == nil {
            let newProfile = UserProfile()
            modelContext.insert(newProfile)
            userProfile = newProfile
            try? modelContext.save()
        }
        
        syncFromProfile()
    }
    
    private func syncFromProfile() {
        guard let profile = userProfile else { return }
        
        userName = profile.name
        fitnessLevel = profile.fitnessLevel
        weeklyGoalMinutes = profile.weeklyGoalMinutes
        dailyReminderEnabled = profile.dailyReminderEnabled
        reminderTime = profile.reminderTime ?? Date()
        soundEnabled = profile.soundEnabled
        hapticsEnabled = profile.hapticsEnabled
        selectedMaximooCharacter = profile.selectedMaximooCharacter
        totalWorkoutsCompleted = profile.totalWorkoutsCompleted
        totalMinutesExercised = profile.totalMinutesExercised
        memberSince = profile.joinedAt
    }
    
    func saveChanges() {
        guard let profile = userProfile else { return }
        
        profile.name = userName
        profile.fitnessLevel = fitnessLevel
        profile.weeklyGoalMinutes = weeklyGoalMinutes
        profile.dailyReminderEnabled = dailyReminderEnabled
        profile.reminderTime = reminderTime
        profile.soundEnabled = soundEnabled
        profile.hapticsEnabled = hapticsEnabled
        profile.selectedMaximooCharacter = selectedMaximooCharacter
        
        try? modelContext.save()
        
        // Update notifications if needed
        if dailyReminderEnabled {
            scheduleReminder()
        } else {
            cancelReminder()
        }
    }
    
    func discardChanges() {
        syncFromProfile()
    }
    
    func selectCharacter(_ characterId: String) {
        selectedMaximooCharacter = characterId
    }
    
    // MARK: - Notifications
    
    private func scheduleReminder() {
        // TODO: Implement UNUserNotificationCenter scheduling
    }
    
    private func cancelReminder() {
        // TODO: Implement UNUserNotificationCenter cancellation
    }
    
    // MARK: - Data Management
    
    func exportData() {
        // TODO: Implement data export
    }
    
    func clearAllData() {
        // Delete all sessions
        let sessionDescriptor = FetchDescriptor<WorkoutSession>()
        if let sessions = try? modelContext.fetch(sessionDescriptor) {
            for session in sessions {
                modelContext.delete(session)
            }
        }
        
        // Reset profile stats
        if let profile = userProfile {
            profile.streakCount = 0
            profile.totalWorkoutsCompleted = 0
            profile.totalMinutesExercised = 0
            profile.lastWorkoutDate = nil
        }
        
        try? modelContext.save()
        syncFromProfile()
    }
}

// MARK: - Supporting Types

struct MaximooCharacter: Identifiable {
    let id: String
    let name: String
    let preview: String
}
