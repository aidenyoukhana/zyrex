//
//  MaximooSceneView.swift
//  Zyrex
//
//  SwiftUI wrapper for displaying Mixamo 3D character animations
//

import SwiftUI
import SceneKit

/// SwiftUI view that displays the Maximoo 3D character with animations
struct MaximooSceneView: UIViewRepresentable {
    let animationService: MaximooAnimationService
    var animationName: String?
    var autoPlay: Bool = true
    var allowsCameraControl: Bool = false
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        
        // Configure the view
        scnView.backgroundColor = .clear
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = allowsCameraControl
        scnView.antialiasingMode = .multisampling4X
        
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        // Always update the scene from the service
        if let scene = animationService.scene {
            if scnView.scene !== scene {
                scnView.scene = scene
            }
            // Always ensure camera is set up correctly
            setupCamera(in: scnView)
        }
    }
    
    private func setupCamera(in scnView: SCNView) {
        guard let scene = scnView.scene else { return }
        
        // Remove any existing custom camera
        scene.rootNode.childNode(withName: "zyrexCamera", recursively: true)?.removeFromParentNode()
        
        // Also remove any cameras that came with the DAE file
        scene.rootNode.enumerateChildNodes { node, _ in
            if node.camera != nil && node.name != "zyrexCamera" {
                node.removeFromParentNode()
            }
        }
        
        // Create our own camera for optimal viewing
        let cameraNode = SCNNode()
        cameraNode.name = "zyrexCamera"
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.automaticallyAdjustsZRange = true
        cameraNode.camera?.fieldOfView = 60
        cameraNode.camera?.zNear = 0.1
        cameraNode.camera?.zFar = 1000
        
        // Position camera for full body view - centered on character, backed out
        cameraNode.position = SCNVector3(0, 60, 350)   // Lower camera, further back
        cameraNode.look(at: SCNVector3(0, 60, 0))      // Look at mid-body height
        
        scene.rootNode.addChildNode(cameraNode)
        scnView.pointOfView = cameraNode
    }
}

/// Preview container for testing animations
struct MaximooPreviewView: View {
    @State private var animationService = MaximooAnimationService()
    let workoutName: String
    
    var body: some View {
        ZStack {
            // 3D Scene
            MaximooSceneView(
                animationService: animationService,
                animationName: workoutName,
                autoPlay: true,
                allowsCameraControl: true
            )
            
            // Overlay controls
            VStack {
                Spacer()
                
                HStack(spacing: 20) {
                    Button {
                        animationService.stopAnimation()
                    } label: {
                        Image(systemName: "stop.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    
                    Button {
                        if animationService.isPlaying {
                            animationService.pauseAnimation()
                        } else {
                            animationService.resumeAnimation()
                        }
                    } label: {
                        Image(systemName: animationService.isPlaying ? "pause.fill" : "play.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    
                    Button {
                        animationService.loadAndPlayAnimation(fileName: workoutName)
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding()
            }
        }
        .onAppear {
            animationService.loadAndPlayAnimation(fileName: workoutName)
        }
    }
}

#Preview {
    MaximooPreviewView(workoutName: "Burpee")
        .ignoresSafeArea()
}
