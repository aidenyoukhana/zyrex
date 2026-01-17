//
//  HomeView.swift
//  Zyrex
//
//  Created by Aiden Youkhana on 1/17/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @State var viewModel: HomeViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Weekly Progress Card
                    weeklyProgressCard
                    
                    // Quick Stats Row
                    quickStatsRow
                    
                    // Recent Activity
                    if !viewModel.recentSessions.isEmpty {
                        recentActivitySection
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(viewModel.greeting)
            .onAppear {
                viewModel.loadData()
            }
        }
    }
    
    // MARK: - Sections
    
    private var weeklyProgressCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weekly Goal")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.weeklyMinutes) / \(viewModel.userProfile?.weeklyGoalMinutes ?? 150) min")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                if viewModel.currentStreak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                        Text("\(viewModel.currentStreak)")
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.orange.opacity(0.15))
                    .clipShape(Capsule())
                }
            }
            
            ProgressView(value: viewModel.weeklyGoalProgress)
                .tint(.orange)
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var quickStatsRow: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Today",
                value: "\(viewModel.todayMinutes)",
                unit: "min",
                icon: "clock.fill",
                color: .blue
            )
            
            StatCard(
                title: "Week",
                value: "\(viewModel.weeklyMinutes)",
                unit: "min",
                icon: "calendar",
                color: .purple
            )
        }
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent")
                .font(.headline)
            
            ForEach(viewModel.recentSessions.prefix(3)) { session in
                RecentSessionRow(session: session)
            }
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct RecentSessionRow: View {
    let session: WorkoutSession
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            
            Text(session.workoutPlan?.name ?? "Quick Workout")
                .font(.subheadline)
            
            Spacer()
            
            Text("\(session.totalDurationSeconds / 60) min")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel(modelContext: ModelContext(try! ModelContainer(for: UserProfile.self))))
}
