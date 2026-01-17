//
//  AnalysisView.swift
//  Zyrex
//
//  Created by Aiden Youkhana on 1/17/26.
//

import SwiftUI
import SwiftData
import Charts

struct AnalysisView: View {
    @State var viewModel: AnalysisViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Time range picker
                    timeRangePicker
                    
                    // Summary stats
                    summaryStats
                    
                    // Weekly chart
                    weeklyChart
                    
                    // Streak info
                    streakSection
                    
                    // Achievements
                    achievementsSection
                    
                    // Recent sessions
                    recentSessionsSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Analysis")
            .onAppear {
                viewModel.loadData()
            }
        }
    }
    
    // MARK: - Time Range Picker
    
    private var timeRangePicker: some View {
        Picker("Time Range", selection: $viewModel.selectedTimeRange) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: viewModel.selectedTimeRange) {
            viewModel.loadData()
        }
    }
    
    // MARK: - Summary Stats
    
    private var summaryStats: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            AnalysisStatCard(
                title: "Workouts",
                value: "\(viewModel.totalWorkouts)",
                icon: "figure.run",
                color: .blue
            )
            
            AnalysisStatCard(
                title: "Minutes",
                value: "\(viewModel.totalMinutes)",
                icon: "clock.fill",
                color: .green
            )
            
            AnalysisStatCard(
                title: "Calories",
                value: "\(viewModel.totalCalories)",
                icon: "flame.fill",
                color: .orange
            )
            
            AnalysisStatCard(
                title: "Avg Form",
                value: "\(Int(viewModel.averageFormScore * 100))%",
                icon: "checkmark.seal.fill",
                color: .purple
            )
        }
    }
    
    // MARK: - Weekly Chart
    
    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity")
                .font(.headline)
            
            if viewModel.weeklyData.isEmpty {
                emptyChartPlaceholder
            } else {
                Chart(viewModel.weeklyData) { data in
                    BarMark(
                        x: .value("Day", data.dayName),
                        y: .value("Minutes", data.minutes)
                    )
                    .foregroundStyle(.orange.gradient)
                    .cornerRadius(4)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel()
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let intValue = value.as(Int.self) {
                                Text("\(intValue)m")
                                    .font(.caption2)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var emptyChartPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No activity yet")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Complete workouts to see your progress")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Streak Section
    
    private var streakSection: some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.title)
                    .foregroundStyle(.orange)
                Text("\(viewModel.currentStreak)")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Current Streak")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.orange.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(spacing: 4) {
                Image(systemName: "trophy.fill")
                    .font(.title)
                    .foregroundStyle(.yellow)
                Text("\(viewModel.longestStreak)")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Best Streak")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.yellow.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    // MARK: - Achievements
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Achievements")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.achievements.filter { $0.isUnlocked }.count) unlocked")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if viewModel.achievements.isEmpty {
                Text("Complete workouts to unlock achievements!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.achievements) { achievement in
                            AchievementCard(achievement: achievement)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Recent Sessions
    
    private var recentSessionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Workout History")
                .font(.headline)
            
            if viewModel.filteredSessions.isEmpty {
                Text("No workouts in this period")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(viewModel.filteredSessions.prefix(10)) { session in
                    SessionHistoryRow(session: session)
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct AnalysisStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: achievement.icon)
                .font(.title)
                .foregroundStyle(achievement.isUnlocked ? .orange : .gray)
            
            Text(achievement.name)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 80)
        .padding()
        .background(achievement.isUnlocked ? .orange.opacity(0.1) : .gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .opacity(achievement.isUnlocked ? 1 : 0.5)
    }
}

struct SessionHistoryRow: View {
    let session: WorkoutSession
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.workoutPlan?.name ?? "Quick Workout")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(session.startedAt, format: .dateTime.month().day().hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(session.totalDurationSeconds / 60) min")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if session.averageFormScore > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption2)
                        Text("\(Int(session.averageFormScore * 100))%")
                    }
                    .font(.caption)
                    .foregroundStyle(.green)
                }
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    AnalysisView(viewModel: AnalysisViewModel(modelContext: ModelContext(try! ModelContainer(for: WorkoutSession.self))))
}
