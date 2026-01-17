//
//  WorkoutDetailView.swift
//  Zyrex
//
//  Shows details for a single Workout (individual movement like squats)
//

import SwiftUI
import SwiftData
import SceneKit

struct WorkoutDetailView: View {
    let workout: Workout
    @Environment(\.modelContext) private var modelContext
    @State private var showingPractice = false
    @State private var animationService = MaximooAnimationService()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Maximoo Preview
                maximooPreview
                
                // Workout info
                infoSection
                
                // Muscle groups
                muscleGroupsSection
                
                // Instructions
                instructionsSection
                
                Spacer(minLength: 80)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            practiceButton
        }
        .fullScreenCover(isPresented: $showingPractice) {
            PracticeSessionView(
                viewModel: PracticeViewModel(modelContext: modelContext),
                workout: workout
            )
        }
    }
    
    private var maximooPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(LinearGradient(
                    colors: [.orange.opacity(0.2), .pink.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(height: 250)
            
            // 3D Animation View
            if !workout.mixamoAnimationName.isEmpty {
                MaximooSceneView(
                    animationService: animationService,
                    animationName: workout.mixamoAnimationName,
                    autoPlay: true,
                    allowsCameraControl: true
                )
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .onAppear {
                    animationService.loadAndPlayAnimation(fileName: workout.mixamoAnimationName)
                }
            } else {
                // Fallback placeholder
                VStack {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 80))
                        .foregroundStyle(.orange)
                    
                    Text("Maximoo Demo")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Image(systemName: "play.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                        .shadow(radius: 4)
                }
            }
        }
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(workout.name)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            HStack(spacing: 16) {
                DifficultyBadge(difficulty: workout.difficulty)
                
                Label(workout.category.rawValue, systemImage: workout.category.icon)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if !workout.workoutDescription.isEmpty {
                Text(workout.workoutDescription)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            
            // Sets/Reps/Duration
            HStack(spacing: 20) {
                if let sets = workout.sets {
                    VStack {
                        Text("\(sets)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Sets")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                if let reps = workout.reps {
                    VStack {
                        Text("\(reps)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Reps")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                VStack {
                    Text("\(workout.durationSeconds)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Seconds")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                VStack {
                    Text("\(workout.restBetweenSetsSeconds)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Rest")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private var muscleGroupsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Muscle Groups")
                .font(.headline)
            
            FlowLayout(spacing: 8) {
                ForEach(workout.muscleGroups, id: \.self) { muscle in
                    Text(muscle.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.orange.opacity(0.15))
                        .foregroundStyle(.orange)
                        .clipShape(Capsule())
                }
            }
        }
    }
    
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Instructions")
                .font(.headline)
            
            ForEach(Array(workout.instructions.enumerated()), id: \.offset) { index, instruction in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(.orange)
                        .clipShape(Circle())
                    
                    Text(instruction)
                        .font(.body)
                }
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var practiceButton: some View {
        Button {
            showingPractice = true
        } label: {
            HStack {
                Image(systemName: "camera.fill")
                Text("Practice with Camera")
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

// MARK: - Flow Layout for Tags

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > width, x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
                
                self.size.width = max(self.size.width, x)
            }
            
            self.size.height = y + lineHeight
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutDetailView(workout: Workout(
            name: "Squats",
            workoutDescription: "A compound lower body exercise.",
            category: .strength,
            difficulty: .beginner,
            muscleGroups: [.quadriceps, .glutes, .core],
            durationSeconds: 45,
            reps: 12,
            sets: 3,
            instructions: ["Stand with feet shoulder-width apart", "Lower your body", "Push through heels"]
        ))
    }
}
