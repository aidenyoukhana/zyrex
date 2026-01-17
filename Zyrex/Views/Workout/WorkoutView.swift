//
//  WorkoutView.swift
//  Zyrex
//
//  Main workout tab view
//

import SwiftUI
import SwiftData

struct WorkoutView: View {
    @State var viewModel: WorkoutViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    if viewModel.filteredWorkouts.isEmpty {
                        emptyState
                    } else {
                        ForEach(viewModel.filteredWorkouts) { workout in
                            NavigationLink {
                                WorkoutDetailView(workout: workout)
                            } label: {
                                WorkoutRow(workout: workout)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Workouts")
            .searchable(text: $viewModel.searchText, prompt: "Search")
            .onAppear {
                viewModel.loadData()
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "dumbbell")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            
            Text("No workouts found")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Workout Row
struct WorkoutRow: View {
    let workout: Workout
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: workout.category.icon)
                .font(.title3)
                .foregroundStyle(.orange)
                .frame(width: 40, height: 40)
                .background(.orange.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(workout.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(workout.muscleGroups.first?.rawValue ?? "Full Body")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            DifficultyBadge(difficulty: workout.difficulty)
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Difficulty Badge
struct DifficultyBadge: View {
    let difficulty: Difficulty
    
    var color: Color {
        switch difficulty {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
    
    var body: some View {
        Text(difficulty.rawValue)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

// MARK: - Preview
#Preview {
    WorkoutView(viewModel: WorkoutViewModel(modelContext: ModelContext(try! ModelContainer(for: Workout.self))))
}
