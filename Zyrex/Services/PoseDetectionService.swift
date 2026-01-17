//
//  PoseDetectionService.swift
//  Zyrex
//
//  Google MediaPipe Pose Detection Service
//

import Foundation
import AVFoundation
import Vision
import UIKit
import OSLog

@MainActor
@Observable
final class PoseDetectionService {
    
    // MARK: - Properties
    
    var currentPose: PoseKeypoints?
    var isProcessing = false
    var errorMessage: String?
    
    // Callback for when pose is detected
    var onPoseDetected: ((PoseKeypoints) -> Void)?
    
    // Processing queue
    private let processingQueue = DispatchQueue(label: "pose.detection.queue", qos: .userInitiated)
    private nonisolated(unsafe) var frameCount: Int32 = 0
    private let processEveryNthFrame: Int32 = 3  // Only process every 3rd frame to reduce lag
    
    // MARK: - Public Methods
    
    /// Process a camera frame for pose detection
    nonisolated func processFrame(_ sampleBuffer: CMSampleBuffer) {
        // Throttle frame processing to reduce lag
        frameCount += 1
        guard frameCount % processEveryNthFrame == 0 else { return }
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        processingQueue.async { [weak self] in
            self?.performPoseDetection(on: pixelBuffer)
        }
    }
    
    // MARK: - Private Methods
    
    nonisolated private func performPoseDetection(on pixelBuffer: CVPixelBuffer) {
        let request = VNDetectHumanBodyPoseRequest()
        // Use .up orientation since camera already handles rotation
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .upMirrored, options: [:])
        
        do {
            try handler.perform([request])
            
            guard let observations = request.results,
                  let observation = observations.first else {
                Task { @MainActor [weak self] in
                    self?.currentPose = nil
                }
                return
            }
            
            // Convert Vision observation to our PoseKeypoints format
            let keypoints = self.convertToPoseKeypoints(observation)
            
            Task { @MainActor [weak self] in
                self?.currentPose = keypoints
                self?.onPoseDetected?(keypoints)
            }
        } catch {
            Task { @MainActor [weak self] in
                self?.errorMessage = "Pose detection failed: \(error.localizedDescription)"
            }
        }
    }
    
    nonisolated private func convertToPoseKeypoints(_ observation: VNHumanBodyPoseObservation) -> PoseKeypoints {
        var keypoints = PoseKeypoints()
        
        // Helper to get landmark
        func getLandmark(_ jointName: VNHumanBodyPoseObservation.JointName) -> PoseLandmark? {
            guard let point = try? observation.recognizedPoint(jointName),
                  point.confidence > 0.1 else {
                return nil
            }
            return PoseLandmark(
                x: Float(point.location.x),
                y: Float(point.location.y),
                z: 0, // Vision doesn't provide Z
                visibility: Float(point.confidence)
            )
        }
        
        // Map Vision joints to our PoseKeypoints
        // Face
        keypoints.nose = getLandmark(.nose)
        keypoints.leftEye = getLandmark(.leftEye)
        keypoints.rightEye = getLandmark(.rightEye)
        keypoints.leftEar = getLandmark(.leftEar)
        keypoints.rightEar = getLandmark(.rightEar)
        
        // Upper body
        keypoints.leftShoulder = getLandmark(.leftShoulder)
        keypoints.rightShoulder = getLandmark(.rightShoulder)
        keypoints.leftElbow = getLandmark(.leftElbow)
        keypoints.rightElbow = getLandmark(.rightElbow)
        keypoints.leftWrist = getLandmark(.leftWrist)
        keypoints.rightWrist = getLandmark(.rightWrist)
        
        // Lower body
        keypoints.leftHip = getLandmark(.leftHip)
        keypoints.rightHip = getLandmark(.rightHip)
        keypoints.leftKnee = getLandmark(.leftKnee)
        keypoints.rightKnee = getLandmark(.rightKnee)
        keypoints.leftAnkle = getLandmark(.leftAnkle)
        keypoints.rightAnkle = getLandmark(.rightAnkle)
        
        return keypoints
    }
}
