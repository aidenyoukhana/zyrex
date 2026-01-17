//
//  WorkoutPlanDetailView.swift
//  Zyrex
//
//  Shows details for a WorkoutPlan (collection of workouts)
//

import SwiftUI
import SwiftData

struct WorkoutPlanDetailView: View {
    let workoutPlan: WorkoutPlan
    @Environment(\.modelContext) private var modelContext
    @State private var showingPractice = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                headerSection
                
                // Stats row
                statsRow
                
                // Description
                if !workoutPlan.planDescription.isEmpty {
                    Text(workoutPlan.planDescription)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                
                // Workouts list
                workoutsSection
                
                Spacer(minLength: 80)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            startButton
        }
        .fullScreenCover(isPresented: $showingPractice) {
            PracticeSessionView(
                viewModel: PracticeViewModel(modelContext: modelContext),
                workoutPlan: workoutPlan
            )
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: workoutPlan.category.icon)
                    .font(.title2)
                    .foregroundStyle(.orange)
                    .padding(12)
                    .background(.orange.opacity(0.15))
                    .clipShape(Circle())
                
                Spacer()
                
                DifficultyBadge(difficulty: workoutPlan.difficulty)
            }
            
            Text(workoutPlan.name)
                .font(.largeTitle)
                .fontWeight(.bold)
        }
    }
    
    private var statsRow: some View {
        HStack(spacing: 20) {
            StatItem(value: "\(workoutPlan.estimatedDurationMinutes)", label: "minutes", icon: "clock")
            StatItem(value: "\(workoutPlan.workouts.count)", label: "workouts", icon: "list.bullet")
            StatItem(value: "\(estimatedCalories)", label: "calories", icon: "flame")
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var estimatedCalories: Int {
        workoutPlan.estimatedDurationMinutes * 7
    }
    
    private var workoutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Workouts")
                .font(.headline)
            
            ForEach(Array(workoutPlan.workouts.enumerated()), id: \.element.id) { index, workout in
                WorkoutListItem(index: index + 1, workout: workout)
            }
        }
    }
    
    private var startButton: some View {
        Button {
            showingPractice = true
        } label: {
            HStack {
                Image(systemName: "play.fill")
                Text("Start Workout Plan")
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.orange)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}

// MARK: - Supporting Views

struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(.orange)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct WorkoutListItem: View {
    let index: Int
    let workout: Workout
    
    var body: some View {
        HStack(spacing: 12) {
            // Index badge
            Text("\(index)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(.orange)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(workout.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    if let reps = workout.reps, let sets = workout.sets {
                        Text("\(sets) sets × \(reps) reps")
                    } else {
                        Text("\(workout.durationSeconds) seconds")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: workout.category.icon)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        WorkoutPlanDetailView(workoutPlan: WorkoutPlan(
            name: "Full Body Burn",
            planDescription: "A complete workout hitting all major muscle groups.",
            category: .strength,
            difficulty: .intermediate,
            workouts: [],
            estimatedDurationMinutes: 30
        ))
    }
}
