//
//  MoveNetService.swift
//  Zyrex
//
//  Core ML Pose Detection - Fast on-device pose estimation
//  Uses Apple's Vision framework with Core ML backend
//  No API key required - runs entirely on device
//

import Foundation
import AVFoundation
import Vision
import CoreML
import UIKit

/// Fast pose detection using Apple's Core ML-powered Vision framework
/// This is Apple's equivalent to MoveNet - optimized for real-time on-device inference
@MainActor
@Observable
final class MoveNetService {
    
    // MARK: - Properties
    
    var currentPose: PoseKeypoints?
    var isProcessing = false
    var errorMessage: String?
    var isModelLoaded = false
    
    // Callback for when pose is detected
    var onPoseDetected: ((PoseKeypoints) -> Void)?
    
    // Processing
    private let processingQueue = DispatchQueue(label: "coreml.pose.queue", qos: .userInteractive)
    private nonisolated(unsafe) var frameCount: Int32 = 0
    private let processEveryNthFrame: Int32 = 2  // Process every 2nd frame
    
    // MARK: - Initialization
    
    init() {
        isModelLoaded = true
    }
    
    // MARK: - Public Methods
    
    /// Process a camera frame for pose detection
    nonisolated func processFrame(_ sampleBuffer: CMSampleBuffer) {
        // Throttle frames for performance
        frameCount += 1
        guard frameCount % processEveryNthFrame == 0 else { return }
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        processingQueue.async { [weak self] in
            self?.detectPose(in: pixelBuffer)
        }
    }
    
    // MARK: - Private Methods
    
    nonisolated private func detectPose(in pixelBuffer: CVPixelBuffer) {
        // Create Vision request - uses Core ML under the hood
        let request = VNDetectHumanBodyPoseRequest()
        
        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: .up,
            options: [:]
        )
        
        do {
            try handler.perform([request])
            
            guard let observation = request.results?.first else {
                Task { @MainActor [weak self] in
                    self?.currentPose = nil
                }
                return
            }
            
            let keypoints = extractKeypoints(from: observation)
            
            Task { @MainActor [weak self] in
                self?.currentPose = keypoints
                self?.onPoseDetected?(keypoints)
            }
        } catch {
            Task { @MainActor [weak self] in
                self?.errorMessage = error.localizedDescription
            }
        }
    }
    
    nonisolated private func extractKeypoints(from observation: VNHumanBodyPoseObservation) -> PoseKeypoints {
        var keypoints = PoseKeypoints()
        
        // Lower confidence threshold for responsive tracking
        func point(_ joint: VNHumanBodyPoseObservation.JointName) -> PoseLandmark? {
            guard let p = try? observation.recognizedPoint(joint), p.confidence > 0.1 else {
                return nil
            }
            return PoseLandmark(
                x: Float(p.location.x),
                y: Float(p.location.y),
                z: 0,
                visibility: Float(p.confidence)
            )
        }
        
        // All 19 Vision body pose landmarks
        keypoints.nose = point(.nose)
        keypoints.leftEye = point(.leftEye)
        keypoints.rightEye = point(.rightEye)
        keypoints.leftEar = point(.leftEar)
        keypoints.rightEar = point(.rightEar)
        keypoints.leftShoulder = point(.leftShoulder)
        keypoints.rightShoulder = point(.rightShoulder)
        keypoints.leftElbow = point(.leftElbow)
        keypoints.rightElbow = point(.rightElbow)
        keypoints.leftWrist = point(.leftWrist)
        keypoints.rightWrist = point(.rightWrist)
        keypoints.leftHip = point(.leftHip)
        keypoints.rightHip = point(.rightHip)
        keypoints.leftKnee = point(.leftKnee)
        keypoints.rightKnee = point(.rightKnee)
        keypoints.leftAnkle = point(.leftAnkle)
        keypoints.rightAnkle = point(.rightAnkle)
        
        return keypoints
    }
}
