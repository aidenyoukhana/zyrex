//
//  AnalysisViewModel.swift
//  Zyrex
//
//  Created by Aiden Youkhana on 1/17/26.
//

import Foundation
import SwiftData

@MainActor
@Observable
final class AnalysisViewModel {
    private let modelContext: ModelContext
    
    var sessions: [WorkoutSession] = []
    var selectedTimeRange: TimeRange = .week
    
    // Stats
    var totalWorkouts: Int = 0
    var totalMinutes: Int = 0
    var totalCalories: Int = 0
    var averageFormScore: Double = 0.0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    
    // Chart data
    var weeklyData: [DailyStats] = []
    var monthlyData: [WeeklyStats] = []
    
    // Achievements
    var achievements: [Achievement] = []
    
    var filteredSessions: [WorkoutSession] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimeRange {
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            return sessions.filter { $0.startedAt >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return sessions.filter { $0.startedAt >= monthAgo }
        case .year:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            return sessions.filter { $0.startedAt >= yearAgo }
        case .allTime:
            return sessions
        }
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func loadData() {
        loadSessions()
        calculateStats()
        generateChartData()
        checkAchievements()
    }
    
    private func loadSessions() {
        let descriptor = FetchDescriptor<WorkoutSession>(
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        sessions = (try? modelContext.fetch(descriptor)) ?? []
    }
    
    private func calculateStats() {
        let filtered = filteredSessions
        
        totalWorkouts = filtered.count
        totalMinutes = filtered.reduce(0) { $0 + ($1.totalDurationSeconds / 60) }
        totalCalories = filtered.reduce(0) { $0 + $1.caloriesBurned }
        
        let scores = filtered.map { $0.averageFormScore }.filter { $0 > 0 }
        averageFormScore = scores.isEmpty ? 0 : scores.reduce(0, +) / Double(scores.count)
        
        calculateStreaks()
    }
    
    private func calculateStreaks() {
        let calendar = Calendar.current
        var streak = 0
        var maxStreak = 0
        var lastDate: Date?
        
        let sortedSessions = sessions.sorted { $0.startedAt > $1.startedAt }
        
        for session in sortedSessions {
            let sessionDay = calendar.startOfDay(for: session.startedAt)
            
            if let last = lastDate {
                let lastDay = calendar.startOfDay(for: last)
                let daysDiff = calendar.dateComponents([.day], from: sessionDay, to: lastDay).day ?? 0
                
                if daysDiff == 1 {
                    streak += 1
                } else if daysDiff > 1 {
                    maxStreak = max(maxStreak, streak)
                    streak = 1
                }
            } else {
                streak = 1
            }
            
            lastDate = session.startedAt
        }
        
        maxStreak = max(maxStreak, streak)
        currentStreak = streak
        longestStreak = maxStreak
    }
    
    private func generateChartData() {
        generateWeeklyData()
        generateMonthlyData()
    }
    
    private func generateWeeklyData() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        weeklyData = (0..<7).reversed().compactMap { daysAgo -> DailyStats? in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { return nil }
            
            let daySessions = sessions.filter { calendar.isDate($0.startedAt, inSameDayAs: date) }
            let minutes = daySessions.reduce(0) { $0 + ($1.totalDurationSeconds / 60) }
            let calories = daySessions.reduce(0) { $0 + $1.caloriesBurned }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            
            return DailyStats(
                date: date,
                dayName: formatter.string(from: date),
                minutes: minutes,
                calories: calories,
                workoutCount: daySessions.count
            )
        }
    }
    
    private func generateMonthlyData() {
        let calendar = Calendar.current
        let today = Date()
        
        monthlyData = (0..<4).reversed().compactMap { weeksAgo -> WeeklyStats? in
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -weeksAgo, to: today),
                  let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) else { return nil }
            
            let weekSessions = sessions.filter { $0.startedAt >= weekStart && $0.startedAt < weekEnd }
            let minutes = weekSessions.reduce(0) { $0 + ($1.totalDurationSeconds / 60) }
            let calories = weekSessions.reduce(0) { $0 + $1.caloriesBurned }
            
            return WeeklyStats(
                weekStart: weekStart,
                weekNumber: calendar.component(.weekOfYear, from: weekStart),
                minutes: minutes,
                calories: calories,
                workoutCount: weekSessions.count
            )
        }
    }
    
    private func checkAchievements() {
        achievements = []
        
        // First workout
        if totalWorkouts >= 1 {
            achievements.append(Achievement(id: "first_workout", name: "First Steps", description: "Complete your first workout", icon: "figure.walk", isUnlocked: true))
        }
        
        // Streak achievements
        if currentStreak >= 7 {
            achievements.append(Achievement(id: "week_streak", name: "Week Warrior", description: "7-day workout streak", icon: "flame.fill", isUnlocked: true))
        }
        
        if currentStreak >= 30 {
            achievements.append(Achievement(id: "month_streak", name: "Monthly Master", description: "30-day workout streak", icon: "star.fill", isUnlocked: true))
        }
        
        // Form achievements
        if averageFormScore >= 0.9 {
            achievements.append(Achievement(id: "perfect_form", name: "Perfect Form", description: "Average form score above 90%", icon: "checkmark.seal.fill", isUnlocked: true))
        }
        
        // Volume achievements
        if totalWorkouts >= 10 {
            achievements.append(Achievement(id: "ten_workouts", name: "Getting Serious", description: "Complete 10 workouts", icon: "10.circle.fill", isUnlocked: true))
        }
        
        if totalWorkouts >= 50 {
            achievements.append(Achievement(id: "fifty_workouts", name: "Dedicated", description: "Complete 50 workouts", icon: "50.circle.fill", isUnlocked: true))
        }
    }
}

// MARK: - Supporting Types

enum TimeRange: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    case allTime = "All Time"
}

struct DailyStats: Identifiable {
    let id = UUID()
    let date: Date
    let dayName: String
    let minutes: Int
    let calories: Int
    let workoutCount: Int
}

struct WeeklyStats: Identifiable {
    let id = UUID()
    let weekStart: Date
    let weekNumber: Int
    let minutes: Int
    let calories: Int
    let workoutCount: Int
}

struct Achievement: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let isUnlocked: Bool
}
