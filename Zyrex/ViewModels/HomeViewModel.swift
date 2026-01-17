//
//  HomeViewModel.swift
//  Zyrex
//
//  Created by Aiden Youkhana on 1/17/26.
//

import Foundation
import SwiftData

@MainActor
@Observable
final class HomeViewModel {
    private let modelContext: ModelContext
    
    var userProfile: UserProfile?
    var recentSessions: [WorkoutSession] = []
    var suggestedWorkoutPlan: WorkoutPlan?
    var todayMinutes: Int = 0
    var weeklyMinutes: Int = 0
    var currentStreak: Int = 0
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default: return "Good Night"
        }
    }
    
    var userName: String {
        userProfile?.name ?? "Athlete"
    }
    
    var weeklyGoalProgress: Double {
        guard let profile = userProfile, profile.weeklyGoalMinutes > 0 else { return 0 }
        return min(Double(weeklyMinutes) / Double(profile.weeklyGoalMinutes), 1.0)
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func loadData() {
        loadUserProfile()
        loadRecentSessions()
        loadSuggestedWorkoutPlan()
        calculateStats()
    }
    
    private func loadUserProfile() {
        let descriptor = FetchDescriptor<UserProfile>()
        userProfile = try? modelContext.fetch(descriptor).first
        
        // Create default profile if none exists
        if userProfile == nil {
            let newProfile = UserProfile()
            modelContext.insert(newProfile)
            userProfile = newProfile
            try? modelContext.save()
        }
    }
    
    private func loadRecentSessions() {
        var descriptor = FetchDescriptor<WorkoutSession>(
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 5
        recentSessions = (try? modelContext.fetch(descriptor)) ?? []
    }
    
    private func loadSuggestedWorkoutPlan() {
        let descriptor = FetchDescriptor<WorkoutPlan>()
        let workoutPlans = (try? modelContext.fetch(descriptor)) ?? []
        suggestedWorkoutPlan = workoutPlans.randomElement()
    }
    
    private func calculateStats() {
        currentStreak = userProfile?.streakCount ?? 0
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today) ?? today
        
        // Calculate today's minutes
        todayMinutes = recentSessions
            .filter { calendar.isDate($0.startedAt, inSameDayAs: today) }
            .reduce(0) { $0 + ($1.totalDurationSeconds / 60) }
        
        // Calculate weekly minutes
        weeklyMinutes = recentSessions
            .filter { $0.startedAt >= weekAgo }
            .reduce(0) { $0 + ($1.totalDurationSeconds / 60) }
    }
}
