//
//  CameraService.swift
//  Zyrex
//
//  Created by Aiden Youkhana on 1/17/26.
//

import AVFoundation
import UIKit

@MainActor
@Observable
final class CameraService: NSObject {
    
    // MARK: - Properties
    
    let captureSession = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    var isAuthorized = false
    var isSessionRunning = false
    var isFrontCamera = true
    var errorMessage: String?
    
    var onFrameCaptured: ((CMSampleBuffer) -> Void)?
    
    // MARK: - Authorization
    
    func checkAuthorization() async {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
        case .notDetermined:
            isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
        case .denied, .restricted:
            isAuthorized = false
            errorMessage = "Camera access denied. Please enable it in Settings."
        @unknown default:
            isAuthorized = false
        }
    }
    
    // MARK: - Session Setup
    
    func setupSession() async {
        guard isAuthorized else { return }
        
        await withCheckedContinuation { continuation in
            sessionQueue.async { [weak self] in
                self?.configureSession()
                continuation.resume()
            }
        }
    }
    
    private func configureSession() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .medium  // Lower resolution for faster processing
        
        // Add video input
        do {
            let position: AVCaptureDevice.Position = isFrontCamera ? .front : .back
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
                Task { @MainActor in
                    self.errorMessage = "Camera not available"
                }
                captureSession.commitConfiguration()
                return
            }
            
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
                videoDeviceInput = videoInput
            }
        } catch {
            Task { @MainActor in
                self.errorMessage = "Could not create video input: \(error.localizedDescription)"
            }
            captureSession.commitConfiguration()
            return
        }
        
        // Add video output
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera.frame.queue"))
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
            
            if let connection = videoOutput.connection(with: .video) {
                connection.videoRotationAngle = 90
                if isFrontCamera {
                    connection.isVideoMirrored = true
                }
            }
        }
        
        captureSession.commitConfiguration()
    }
    
    // MARK: - Session Control
    
    func start() {
        guard isAuthorized, !isSessionRunning else { return }
        
        sessionQueue.async { [weak self] in
            self?.captureSession.startRunning()
            Task { @MainActor in
                self?.isSessionRunning = self?.captureSession.isRunning ?? false
            }
        }
    }
    
    func stop() {
        guard isSessionRunning else { return }
        
        sessionQueue.async { [weak self] in
            self?.captureSession.stopRunning()
            Task { @MainActor in
                self?.isSessionRunning = false
            }
        }
    }
    
    // MARK: - Camera Switch
    
    func toggleCamera() {
        isFrontCamera.toggle()
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.captureSession.beginConfiguration()
            
            // Remove existing input
            if let currentInput = self.videoDeviceInput {
                self.captureSession.removeInput(currentInput)
            }
            
            // Add new input
            let position: AVCaptureDevice.Position = self.isFrontCamera ? .front : .back
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
                  let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
                  self.captureSession.canAddInput(videoInput) else {
                self.captureSession.commitConfiguration()
                return
            }
            
            self.captureSession.addInput(videoInput)
            self.videoDeviceInput = videoInput
            
            // Update connection for mirroring
            if let connection = self.videoOutput.connection(with: .video) {
                connection.videoRotationAngle = 90
                connection.isVideoMirrored = self.isFrontCamera
            }
            
            self.captureSession.commitConfiguration()
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        Task { @MainActor in
            onFrameCaptured?(sampleBuffer)
        }
    }
}
