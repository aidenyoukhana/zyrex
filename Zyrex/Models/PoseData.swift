//
//  PoseData.swift
//  Zyrex
//
//  Created by Aiden Youkhana on 1/17/26.
//

import Foundation
import SwiftData

/// Represents a single pose landmark detected by MediaPipe
struct PoseLandmark: Codable, Equatable {
    let x: Float
    let y: Float
    let z: Float
    let visibility: Float
    
    var isVisible: Bool {
        visibility > 0.5
    }
}

/// All 33 MediaPipe pose landmarks
struct PoseKeypoints: Codable, Equatable {
    // Face
    var nose: PoseLandmark?
    var leftEyeInner: PoseLandmark?
    var leftEye: PoseLandmark?
    var leftEyeOuter: PoseLandmark?
    var rightEyeInner: PoseLandmark?
    var rightEye: PoseLandmark?
    var rightEyeOuter: PoseLandmark?
    var leftEar: PoseLandmark?
    var rightEar: PoseLandmark?
    var mouthLeft: PoseLandmark?
    var mouthRight: PoseLandmark?
    
    // Upper body
    var leftShoulder: PoseLandmark?
    var rightShoulder: PoseLandmark?
    var leftElbow: PoseLandmark?
    var rightElbow: PoseLandmark?
    var leftWrist: PoseLandmark?
    var rightWrist: PoseLandmark?
    var leftPinky: PoseLandmark?
    var rightPinky: PoseLandmark?
    var leftIndex: PoseLandmark?
    var rightIndex: PoseLandmark?
    var leftThumb: PoseLandmark?
    var rightThumb: PoseLandmark?
    
    // Lower body
    var leftHip: PoseLandmark?
    var rightHip: PoseLandmark?
    var leftKnee: PoseLandmark?
    var rightKnee: PoseLandmark?
    var leftAnkle: PoseLandmark?
    var rightAnkle: PoseLandmark?
    var leftHeel: PoseLandmark?
    var rightHeel: PoseLandmark?
    var leftFootIndex: PoseLandmark?
    var rightFootIndex: PoseLandmark?
}

/// Recorded pose data for a practice session
@Model
final class PoseSnapshot {
    var id: UUID
    var timestamp: Date
    var keypoints: Data? // Encoded PoseKeypoints
    var formScore: Double
    var feedback: String?
    
    init(
        id: UUID = UUID(),
        timestamp: Date = .now,
        keypoints: Data? = nil,
        formScore: Double = 0.0,
        feedback: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.keypoints = keypoints
        self.formScore = formScore
        self.feedback = feedback
    }
}
