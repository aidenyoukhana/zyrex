//
//  PracticeSessionView.swift
//  Zyrex
//
//  Created by Aiden Youkhana on 1/17/26.
//

import SwiftUI
import SwiftData

struct PracticeSessionView: View {
    @State var viewModel: PracticeViewModel
    @Environment(\.dismiss) private var dismiss
    
    var workout: Workout?
    var workoutPlan: WorkoutPlan?
    
    @State private var timer: Timer?
    @State private var showingExitConfirmation = false
    @State private var cameraService = CameraService()
    @State private var moveNetService = MoveNetService()  // Using MoveNet for faster detection
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Camera feed background
                cameraView
                
                // Overlay UI
                VStack {
                    // Top bar
                    topBar
                    
                    Spacer()
                    
                    // Bottom controls
                    bottomControls
                }
            }
        }
        .ignoresSafeArea()
        .statusBarHidden()
        .task {
            await cameraService.checkAuthorization()
            await cameraService.setupSession()
            
            // Wire up MoveNet pose detection to camera frames
            cameraService.onFrameCaptured = { sampleBuffer in
                moveNetService.processFrame(sampleBuffer)
            }
            
            // Wire up pose updates to view model
            moveNetService.onPoseDetected = { keypoints in
                viewModel.poseKeypoints = keypoints
                viewModel.updateFormScore(from: keypoints)
            }
            
            cameraService.start()
        }
        .onAppear {
            startSession()
        }
        .onDisappear {
            cameraService.stop()
            stopTimer()
        }
        .confirmationDialog("End Workout?", isPresented: $showingExitConfirmation) {
            Button("End Workout", role: .destructive) {
                viewModel.stop()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your progress will be saved.")
        }
    }
    
    // MARK: - Camera View
    
    private var cameraView: some View {
        ZStack {
            // Always show black background first
            Color.black
            
            if cameraService.isAuthorized && cameraService.isSessionRunning {
                CameraPreviewView(session: cameraService.captureSession)
            } else {
                // Permission denied, not yet determined, or session not running
                VStack(spacing: 12) {
                    if !cameraService.isAuthorized {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.white.opacity(0.3))
                        Text(cameraService.errorMessage ?? "Requesting camera access...")
                            .foregroundStyle(.white.opacity(0.5))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    } else {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.5)
                        Text("Starting camera...")
                            .foregroundStyle(.white.opacity(0.5))
                            .padding(.top, 8)
                    }
                }
            }
            
            // Pose overlay (skeleton drawing)
            if viewModel.isPoseDetectionEnabled {
                PoseOverlayView(keypoints: viewModel.poseKeypoints)
            }
            
            // Maximoo demo (picture-in-picture)
            maximooPiP
        }
    }
    
    private var maximooPiP: some View {
        VStack {
            HStack {
                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .frame(width: 120, height: 160)
                    
                    VStack {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 40))
                            .foregroundStyle(.orange)
                        Text("Maximoo")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.trailing, 16)
                .padding(.top, 100)
            }
            Spacer()
        }
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        VStack(spacing: 16) {
            // Status bar background
            Color.clear.frame(height: 50)
            
            HStack {
                // Close button
                Button {
                    showingExitConfirmation = true
                } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                
                Spacer()
                
                // Workout info
                VStack(spacing: 2) {
                    Text(viewModel.currentWorkout?.name ?? "Practice")
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    if let workoutPlan = viewModel.currentWorkoutPlan {
                        Text("\(viewModel.workoutIndex + 1) of \(workoutPlan.workouts.count)")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                
                Spacer()
                
                // Camera flip button
                Button {
                    cameraService.toggleCamera()
                } label: {
                    Image(systemName: "camera.rotate")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            
            // Form score indicator
            formScoreBar
        }
    }
    
    private var formScoreBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Form Score")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                
                Spacer()
                
                Text("\(Int(viewModel.currentFormScore * 100))%")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(formScoreColor)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.2))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(formScoreColor)
                        .frame(width: geo.size.width * viewModel.currentFormScore, height: 8)
                }
            }
            .frame(height: 8)
            
            Text(viewModel.formFeedback)
                .font(.subheadline)
                .foregroundStyle(.white)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
    
    private var formScoreColor: Color {
        switch viewModel.currentFormScore {
        case 0.8...1.0: return .green
        case 0.6..<0.8: return .yellow
        case 0.4..<0.6: return .orange
        default: return .red
        }
    }
    
    // MARK: - Bottom Controls
    
    private var bottomControls: some View {
        VStack(spacing: 16) {
            // Timer display
            timerDisplay
            
            // Rep/Set counter
            if viewModel.currentWorkout?.reps != nil {
                repSetCounter
            }
            
            // Control buttons
            controlButtons
            
            // Bottom safe area
            Color.clear.frame(height: 30)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.clear, .black.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private var timerDisplay: some View {
        VStack(spacing: 4) {
            if viewModel.isResting {
                Text("Rest")
                    .font(.caption)
                    .foregroundStyle(.orange)
                Text(viewModel.restTimerDisplay)
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundStyle(.orange)
            } else {
                Text(viewModel.timerDisplay)
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.2))
                        .frame(height: 4)
                    
                    Capsule()
                        .fill(.orange)
                        .frame(width: geo.size.width * viewModel.progress, height: 4)
                }
            }
            .frame(height: 4)
        }
    }
    
    private var repSetCounter: some View {
        HStack(spacing: 30) {
            VStack {
                Text("\(viewModel.currentSet)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                Text("Set")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            VStack {
                Text("\(viewModel.currentRep)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                Text("Reps")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }
    
    private var controlButtons: some View {
        HStack(spacing: 30) {
            // Restart
            Button {
                viewModel.restart()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            
            // Play/Pause
            Button {
                if viewModel.isPlaying && !viewModel.isPaused {
                    viewModel.pause()
                } else if viewModel.isPaused {
                    viewModel.resume()
                } else {
                    viewModel.play()
                }
            } label: {
                Image(systemName: viewModel.isPlaying && !viewModel.isPaused ? "pause.fill" : "play.fill")
                    .font(.title)
                    .foregroundStyle(.black)
                    .frame(width: 70, height: 70)
                    .background(.orange)
                    .clipShape(Circle())
            }
            
            // Skip
            Button {
                viewModel.skip()
            } label: {
                Image(systemName: "forward.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
        }
    }
    
    // MARK: - Actions
    
    private func startSession() {
        if let workoutPlan = workoutPlan {
            viewModel.startSession(with: workoutPlan)
        } else if let workout = workout {
            viewModel.startSession(with: workout)
        }
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                viewModel.tick()
                simulatePoseDetection()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func simulatePoseDetection() {
        // TODO: Replace with actual MediaPipe pose detection
        // Simulating pose updates for now
        viewModel.currentFormScore = Double.random(in: 0.75...0.98)
    }
}

// MARK: - Pose Overlay View

struct PoseOverlayView: View {
    let keypoints: PoseKeypoints?
    
    // Colors
    let markerColor = Color.green
    let lineColor = Color.green
    let bodyFillColor = Color.green.opacity(0.3)
    
    var body: some View {
        GeometryReader { geometry in
            if let keypoints = keypoints {
                Canvas { context, size in
                    // Draw body fill first (behind everything)
                    drawBodyFill(context: context, size: size, keypoints: keypoints)
                    
                    // Draw connections
                    drawConnections(context: context, size: size, keypoints: keypoints)
                    
                    // Draw joints on top
                    drawJoints(context: context, size: size, keypoints: keypoints)
                }
            }
        }
    }
    
    // MARK: - Draw Body Fill
    
    private func drawBodyFill(context: GraphicsContext, size: CGSize, keypoints: PoseKeypoints) {
        // Draw torso fill
        if let leftShoulder = keypoints.leftShoulder, let rightShoulder = keypoints.rightShoulder,
           let leftHip = keypoints.leftHip, let rightHip = keypoints.rightHip,
           leftShoulder.isVisible, rightShoulder.isVisible, leftHip.isVisible, rightHip.isVisible {
            
            var torsoPath = Path()
            let ls = convertToScreen(landmark: leftShoulder, size: size)
            let rs = convertToScreen(landmark: rightShoulder, size: size)
            let lh = convertToScreen(landmark: leftHip, size: size)
            let rh = convertToScreen(landmark: rightHip, size: size)
            
            torsoPath.move(to: ls)
            torsoPath.addLine(to: rs)
            torsoPath.addLine(to: rh)
            torsoPath.addLine(to: lh)
            torsoPath.closeSubpath()
            
            context.fill(torsoPath, with: .color(bodyFillColor))
        }
        
        // Draw left arm fill
        drawLimbFill(context: context, size: size,
                     joint1: keypoints.leftShoulder,
                     joint2: keypoints.leftElbow,
                     joint3: keypoints.leftWrist,
                     width: 25)
        
        // Draw right arm fill
        drawLimbFill(context: context, size: size,
                     joint1: keypoints.rightShoulder,
                     joint2: keypoints.rightElbow,
                     joint3: keypoints.rightWrist,
                     width: 25)
        
        // Draw left leg fill
        drawLimbFill(context: context, size: size,
                     joint1: keypoints.leftHip,
                     joint2: keypoints.leftKnee,
                     joint3: keypoints.leftAnkle,
                     width: 30)
        
        // Draw right leg fill
        drawLimbFill(context: context, size: size,
                     joint1: keypoints.rightHip,
                     joint2: keypoints.rightKnee,
                     joint3: keypoints.rightAnkle,
                     width: 30)
        
        // Draw head fill
        if let nose = keypoints.nose, nose.isVisible {
            let nosePoint = convertToScreen(landmark: nose, size: size)
            let headRadius: CGFloat = 40
            let headRect = CGRect(x: nosePoint.x - headRadius, y: nosePoint.y - headRadius * 1.2,
                                  width: headRadius * 2, height: headRadius * 2.2)
            context.fill(Path(ellipseIn: headRect), with: .color(bodyFillColor))
        }
    }
    
    private func drawLimbFill(context: GraphicsContext, size: CGSize,
                              joint1: PoseLandmark?, joint2: PoseLandmark?, joint3: PoseLandmark?,
                              width: CGFloat) {
        // Draw thick rounded line between joints to create limb fill
        guard let j1 = joint1, let j2 = joint2, j1.isVisible, j2.isVisible else { return }
        
        let p1 = convertToScreen(landmark: j1, size: size)
        let p2 = convertToScreen(landmark: j2, size: size)
        
        var path1 = Path()
        path1.move(to: p1)
        path1.addLine(to: p2)
        context.stroke(path1, with: .color(bodyFillColor), style: StrokeStyle(lineWidth: width, lineCap: .round))
        
        if let j3 = joint3, j3.isVisible {
            let p3 = convertToScreen(landmark: j3, size: size)
            var path2 = Path()
            path2.move(to: p2)
            path2.addLine(to: p3)
            context.stroke(path2, with: .color(bodyFillColor), style: StrokeStyle(lineWidth: width * 0.8, lineCap: .round))
        }
    }
    
    // MARK: - Draw Connections
    
    private func drawConnections(context: GraphicsContext, size: CGSize, keypoints: PoseKeypoints) {
        // Define skeleton connections
        let connections: [(PoseLandmark?, PoseLandmark?)] = [
            // Face
            (keypoints.leftEar, keypoints.leftEye),
            (keypoints.leftEye, keypoints.nose),
            (keypoints.nose, keypoints.rightEye),
            (keypoints.rightEye, keypoints.rightEar),
            
            // Torso
            (keypoints.leftShoulder, keypoints.rightShoulder),
            (keypoints.leftShoulder, keypoints.leftHip),
            (keypoints.rightShoulder, keypoints.rightHip),
            (keypoints.leftHip, keypoints.rightHip),
            
            // Left arm
            (keypoints.leftShoulder, keypoints.leftElbow),
            (keypoints.leftElbow, keypoints.leftWrist),
            
            // Right arm
            (keypoints.rightShoulder, keypoints.rightElbow),
            (keypoints.rightElbow, keypoints.rightWrist),
            
            // Left leg
            (keypoints.leftHip, keypoints.leftKnee),
            (keypoints.leftKnee, keypoints.leftAnkle),
            
            // Right leg
            (keypoints.rightHip, keypoints.rightKnee),
            (keypoints.rightKnee, keypoints.rightAnkle),
        ]
        
        for (start, end) in connections {
            guard let start = start, let end = end,
                  start.isVisible, end.isVisible else { continue }
            
            let startPoint = convertToScreen(landmark: start, size: size)
            let endPoint = convertToScreen(landmark: end, size: size)
            
            var path = Path()
            path.move(to: startPoint)
            path.addLine(to: endPoint)
            
            context.stroke(path, with: .color(lineColor), lineWidth: 3)
        }
    }
    
    // MARK: - Draw Joints
    
    private func drawJoints(context: GraphicsContext, size: CGSize, keypoints: PoseKeypoints) {
        let allLandmarks: [PoseLandmark?] = [
            keypoints.nose,
            keypoints.leftEye,
            keypoints.rightEye,
            keypoints.leftEar,
            keypoints.rightEar,
            keypoints.leftShoulder,
            keypoints.rightShoulder,
            keypoints.leftElbow,
            keypoints.rightElbow,
            keypoints.leftWrist,
            keypoints.rightWrist,
            keypoints.leftHip,
            keypoints.rightHip,
            keypoints.leftKnee,
            keypoints.rightKnee,
            keypoints.leftAnkle,
            keypoints.rightAnkle,
        ]
        
        for landmark in allLandmarks {
            guard let landmark = landmark, landmark.isVisible else { continue }
            
            let point = convertToScreen(landmark: landmark, size: size)
            let radius: CGFloat = 6
            
            // Outer circle (white border)
            let outerRect = CGRect(x: point.x - radius - 2, y: point.y - radius - 2, width: (radius + 2) * 2, height: (radius + 2) * 2)
            context.fill(Path(ellipseIn: outerRect), with: .color(.white))
            
            // Inner circle (green)
            let innerRect = CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)
            context.fill(Path(ellipseIn: innerRect), with: .color(markerColor))
        }
    }
    
    // MARK: - Coordinate Conversion
    
    private func convertToScreen(landmark: PoseLandmark, size: CGSize) -> CGPoint {
        // Vision coordinates: (0,0) is bottom-left, (1,1) is top-right
        // Screen coordinates: (0,0) is top-left
        // Mirror X to match front camera mirror effect
        let x = (1 - CGFloat(landmark.x)) * size.width  // Mirror X for front camera
        let y = (1 - CGFloat(landmark.y)) * size.height // Flip Y axis
        return CGPoint(x: x, y: y)
    }
}

#Preview {
    PracticeSessionView(
        viewModel: PracticeViewModel(modelContext: ModelContext(try! ModelContainer(for: Workout.self))),
        workout: Workout(
            name: "Squats",
            category: .strength,
            difficulty: .beginner,
            durationSeconds: 45,
            reps: 12,
            sets: 3
        )
    )
}
