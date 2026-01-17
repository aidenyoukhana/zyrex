//
//  PracticeViewModel.swift
//  Zyrex
//
//  Created by Aiden Youkhana on 1/17/26.
//

import Foundation
import SwiftData
import AVFoundation

@MainActor
@Observable
final class PracticeViewModel {
    private let modelContext: ModelContext
    
    // Current workout
    var currentWorkout: Workout?
    var currentWorkoutPlan: WorkoutPlan?
    var workoutIndex: Int = 0
    
    // Timer state
    var isPlaying: Bool = false
    var isPaused: Bool = false
    var elapsedSeconds: Int = 0
    var remainingSeconds: Int = 0
    var currentRep: Int = 0
    var currentSet: Int = 1
    
    // Rest timer
    var isResting: Bool = false
    var restRemainingSeconds: Int = 0
    
    // Pose detection
    var isPoseDetectionEnabled: Bool = true
    var currentFormScore: Double = 0.0
    var formFeedback: String = "Position yourself in frame"
    var poseKeypoints: PoseKeypoints?
    
    // Camera
    var isCameraReady: Bool = false
    var isFrontCamera: Bool = true
    
    // Session tracking
    var sessionStartTime: Date?
    var totalRepsCompleted: Int = 0
    var averageFormScore: Double = 0.0
    private var formScores: [Double] = []
    
    var totalWorkouts: Int {
        currentWorkoutPlan?.workouts.count ?? 1
    }
    
    var progress: Double {
        guard let workout = currentWorkout else { return 0 }
        let total = workout.durationSeconds
        guard total > 0 else { return 0 }
        return Double(elapsedSeconds) / Double(total)
    }
    
    var formScoreColor: String {
        switch currentFormScore {
        case 0.8...1.0: return "green"
        case 0.6..<0.8: return "yellow"
        case 0.4..<0.6: return "orange"
        default: return "red"
        }
    }
    
    var timerDisplay: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var restTimerDisplay: String {
        let minutes = restRemainingSeconds / 60
        let seconds = restRemainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Session Control
    
    func startSession(with workout: Workout) {
        currentWorkout = workout
        currentWorkoutPlan = nil
        workoutIndex = 0
        resetTimers()
        sessionStartTime = Date()
    }
    
    func startSession(with workoutPlan: WorkoutPlan) {
        currentWorkoutPlan = workoutPlan
        workoutIndex = 0
        currentWorkout = workoutPlan.workouts.first
        resetTimers()
        sessionStartTime = Date()
    }
    
    private func resetTimers() {
        elapsedSeconds = 0
        remainingSeconds = currentWorkout?.durationSeconds ?? 30
        currentRep = 0
        currentSet = 1
        isPlaying = false
        isPaused = false
        isResting = false
        formScores = []
    }
    
    // MARK: - Playback Control
    
    func play() {
        isPlaying = true
        isPaused = false
    }
    
    func pause() {
        isPaused = true
    }
    
    func resume() {
        isPaused = false
    }
    
    func stop() {
        isPlaying = false
        isPaused = false
        saveSession()
    }
    
    func skip() {
        moveToNextWorkout()
    }
    
    func restart() {
        resetTimers()
    }
    
    // MARK: - Timer Updates
    
    func tick() {
        guard isPlaying, !isPaused else { return }
        
        if isResting {
            if restRemainingSeconds > 0 {
                restRemainingSeconds -= 1
            } else {
                isResting = false
                startNextSet()
            }
        } else {
            elapsedSeconds += 1
            remainingSeconds = max(0, (currentWorkout?.durationSeconds ?? 30) - elapsedSeconds)
            
            if remainingSeconds == 0 {
                completeCurrentWorkout()
            }
        }
    }
    
    func repCompleted() {
        currentRep += 1
        totalRepsCompleted += 1
        recordFormScore()
        
        if let reps = currentWorkout?.reps, currentRep >= reps {
            completeSet()
        }
    }
    
    private func completeSet() {
        guard let workout = currentWorkout,
              let sets = workout.sets,
              currentSet < sets else {
            completeCurrentWorkout()
            return
        }
        
        currentSet += 1
        currentRep = 0
        isResting = true
        restRemainingSeconds = workout.restBetweenSetsSeconds
    }
    
    private func startNextSet() {
        elapsedSeconds = 0
        remainingSeconds = currentWorkout?.durationSeconds ?? 30
    }
    
    private func completeCurrentWorkout() {
        if currentWorkoutPlan != nil {
            moveToNextWorkout()
        } else {
            stop()
        }
    }
    
    private func moveToNextWorkout() {
        guard let workoutPlan = currentWorkoutPlan else { return }
        
        workoutIndex += 1
        if workoutIndex < workoutPlan.workouts.count {
            currentWorkout = workoutPlan.workouts[workoutIndex]
            resetTimers()
            // Auto-play next workout
            play()
        } else {
            // Workout plan complete
            stop()
        }
    }
    
    // MARK: - Pose Detection
    
    func updatePoseKeypoints(_ keypoints: PoseKeypoints) {
        self.poseKeypoints = keypoints
        analyzePose()
    }
    
    func updateFormScore(from keypoints: PoseKeypoints) {
        self.poseKeypoints = keypoints
        analyzePose()
    }
    
    private func analyzePose() {
        guard let keypoints = poseKeypoints else {
            formFeedback = "Position yourself in frame"
            return
        }
        
        // Check if we have enough visible landmarks
        let visibleLandmarks = [
            keypoints.leftShoulder,
            keypoints.rightShoulder,
            keypoints.leftHip,
            keypoints.rightHip,
            keypoints.leftKnee,
            keypoints.rightKnee
        ].compactMap { $0 }.filter { $0.isVisible }
        
        if visibleLandmarks.count < 4 {
            formFeedback = "Make sure your full body is visible"
            currentFormScore = 0.0
            return
        }
        
        // Basic form analysis - check body alignment
        var score = 1.0
        
        // Check shoulder alignment (should be relatively level)
        if let leftShoulder = keypoints.leftShoulder, let rightShoulder = keypoints.rightShoulder {
            let shoulderDiff = abs(leftShoulder.y - rightShoulder.y)
            if shoulderDiff > 0.1 {
                score -= 0.2
            }
        }
        
        // Check hip alignment
        if let leftHip = keypoints.leftHip, let rightHip = keypoints.rightHip {
            let hipDiff = abs(leftHip.y - rightHip.y)
            if hipDiff > 0.1 {
                score -= 0.2
            }
        }
        
        currentFormScore = max(0, min(1, score))
        
        if currentFormScore >= 0.9 {
            formFeedback = "Perfect form! 🎯"
        } else if currentFormScore >= 0.8 {
            formFeedback = "Great form! Keep it up!"
        } else if currentFormScore >= 0.7 {
            formFeedback = "Good! Watch your posture"
        } else if currentFormScore >= 0.5 {
            formFeedback = "Adjust your position"
        } else {
            formFeedback = "Check your form"
        }
    }
    
    private func recordFormScore() {
        formScores.append(currentFormScore)
        averageFormScore = formScores.reduce(0, +) / Double(formScores.count)
    }
    
    // MARK: - Camera
    
    func toggleCamera() {
        isFrontCamera.toggle()
    }
    
    func setCameraReady(_ ready: Bool) {
        isCameraReady = ready
    }
    
    // MARK: - Session Persistence
    
    private func saveSession() {
        guard let startTime = sessionStartTime else { return }
        
        let session = WorkoutSession(
            workoutPlan: currentWorkoutPlan,
            startedAt: startTime,
            completedAt: Date(),
            totalDurationSeconds: Int(Date().timeIntervalSince(startTime)),
            workoutsCompleted: workoutIndex + 1,
            totalWorkouts: totalWorkouts,
            averageFormScore: averageFormScore,
            caloriesBurned: estimateCaloriesBurned()
        )
        
        modelContext.insert(session)
        try? modelContext.save()
    }
    
    private func estimateCaloriesBurned() -> Int {
        // Rough estimate: 5-10 calories per minute of moderate exercise
        guard let startTime = sessionStartTime else { return 0 }
        let minutes = Int(Date().timeIntervalSince(startTime) / 60)
        return minutes * 7 // ~7 cal/min average
    }
}
