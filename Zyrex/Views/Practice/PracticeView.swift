//
//  PracticeView.swift
//  Zyrex
//
//  Created by Aiden Youkhana on 1/17/26.
//

import SwiftUI
import SwiftData

struct PracticeView: View {
    @State var viewModel: PracticeViewModel
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Workout.name) private var workouts: [Workout]
    @State private var selectedWorkout: Workout?
    @State private var showingSession = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Quick start
                    quickStartButton
                    
                    // Workout grid
                    if !workouts.isEmpty {
                        workoutGrid
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Practice")
            .fullScreenCover(isPresented: $showingSession) {
                PracticeSessionView(
                    viewModel: PracticeViewModel(modelContext: modelContext),
                    workout: selectedWorkout
                )
            }
        }
    }
    
    private var quickStartButton: some View {
        Button {
            selectedWorkout = nil  // Free practice mode - no specific workout
            showingSession = true
        } label: {
            HStack {
                Image(systemName: "camera.viewfinder")
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Free Practice")
                        .font(.headline)
                    Text("Practice any movement")
                        .font(.caption)
                        .opacity(0.8)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
            }
            .foregroundStyle(.white)
            .padding()
            .background(
                LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private var workoutGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose Workout")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(workouts.prefix(6)) { workout in
                    PracticeWorkoutCard(workout: workout) {
                        selectedWorkout = workout
                        showingSession = true
                    }
                }
            }
        }
    }
}

struct PracticeWorkoutCard: View {
    let workout: Workout
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: workout.category.icon)
                    .font(.title2)
                    .foregroundStyle(.orange)
                
                Text(workout.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PracticeView(viewModel: PracticeViewModel(modelContext: ModelContext(try! ModelContainer(for: Workout.self))))
}
