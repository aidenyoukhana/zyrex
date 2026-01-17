//
//  MaximooAnimationService.swift
//  Zyrex
//
//  Service for loading and playing Mixamo character animations
//

import Foundation
import SceneKit

@MainActor
@Observable
final class MaximooAnimationService {
    
    // MARK: - Properties
    
    private(set) var scene: SCNScene?
    private(set) var characterNode: SCNNode?
    private(set) var isPlaying: Bool = false
    private(set) var currentAnimationName: String?
    
    // MARK: - Scene Setup
    
    /// Load the Maximoo character from an animation file (the character is embedded)
    func loadCharacter(named characterName: String = "Maximoo") {
        // Create a new scene
        scene = SCNScene()
        setupDefaultScene()
    }
    
    /// Load character directly from an animation DAE file
    func loadCharacterFromAnimation(fileName: String) {
        // Try .dae first - check various bundle locations
        let possiblePaths = [
            "Animations/Workouts/\(fileName)",
            "Workouts/\(fileName)",
            fileName
        ]
        
        for path in possiblePaths {
            if let url = Bundle.main.url(forResource: path, withExtension: "dae") {
                loadScene(from: url, fileName: fileName)
                return
            }
        }
        
        // Try with subdirectory parameter
        if let url = Bundle.main.url(forResource: fileName, withExtension: "dae", subdirectory: "Animations/Workouts") {
            loadScene(from: url, fileName: fileName)
            return
        }
        
        // Fallback to empty scene
        print("⚠️ Could not find \(fileName).dae in bundle, creating empty scene")
        scene = SCNScene()
        setupDefaultScene()
    }
    
    private func loadScene(from url: URL, fileName: String) {
        do {
            scene = try SCNScene(url: url, options: [
                .checkConsistency: false,
                .flattenScene: false
            ])
            characterNode = scene?.rootNode
            
            // Clear background for transparency
            scene?.background.contents = UIColor.clear
            
            setupLighting()
            print("✅ Loaded scene from: \(url.lastPathComponent)")
        } catch {
            print("⚠️ Error loading DAE: \(error)")
            scene = SCNScene()
            setupDefaultScene()
        }
    }
    
    private func setupLighting() {
        guard let scene = scene else { return }
        
        // Add ambient light
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(white: 0.6, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLight)
        
        // Add directional light
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.color = UIColor(white: 0.9, alpha: 1.0)
        directionalLight.light?.castsShadow = true
        directionalLight.position = SCNVector3(5, 10, 10)
        directionalLight.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(directionalLight)
    }
    
    /// Create a basic scene setup
    private func setupDefaultScene() {
        guard let scene = scene else { return }
        
        // Clear background for transparency
        scene.background.contents = UIColor.clear
        
        setupLighting()
    }
    
    // MARK: - Animation Loading & Playback
    
    /// Load and play animation from a DAE file
    func loadAndPlayAnimation(fileName: String) {
        // Load the scene which contains both character and animation
        loadCharacterFromAnimation(fileName: fileName)
        
        guard let scene = scene else {
            print("⚠️ No scene loaded")
            return
        }
        
        // Find and play animations in the scene
        playAllAnimations(in: scene.rootNode)
        
        currentAnimationName = fileName
        isPlaying = true
    }
    
    /// Recursively find and play all animations in a node hierarchy
    private func playAllAnimations(in node: SCNNode) {
        // Check for animation keys on this node
        for key in node.animationKeys {
            if let player = node.animationPlayer(forKey: key) {
                player.animation.isRemovedOnCompletion = false
                player.animation.repeatCount = .greatestFiniteMagnitude
                player.play()
                print("▶️ Playing animation: \(key) on node: \(node.name ?? "unnamed")")
            }
        }
        
        // Check children
        for child in node.childNodes {
            playAllAnimations(in: child)
        }
    }
    
    // MARK: - Playback Control
    
    /// Play an animation by name
    func playAnimation(named animationName: String, fromFile fileName: String) {
        loadAndPlayAnimation(fileName: fileName)
    }
    
    /// Stop all animations
    func stopAnimation() {
        guard let rootNode = scene?.rootNode else { return }
        stopAllAnimations(in: rootNode)
        isPlaying = false
        currentAnimationName = nil
    }
    
    private func stopAllAnimations(in node: SCNNode) {
        for key in node.animationKeys {
            node.animationPlayer(forKey: key)?.stop()
        }
        for child in node.childNodes {
            stopAllAnimations(in: child)
        }
    }
    
    /// Pause animations
    func pauseAnimation() {
        guard let rootNode = scene?.rootNode else { return }
        pauseAllAnimations(in: rootNode)
        isPlaying = false
    }
    
    private func pauseAllAnimations(in node: SCNNode) {
        for key in node.animationKeys {
            node.animationPlayer(forKey: key)?.paused = true
        }
        for child in node.childNodes {
            pauseAllAnimations(in: child)
        }
    }
    
    /// Resume animations
    func resumeAnimation() {
        guard let rootNode = scene?.rootNode else { return }
        resumeAllAnimations(in: rootNode)
        isPlaying = true
    }
    
    private func resumeAllAnimations(in node: SCNNode) {
        for key in node.animationKeys {
            node.animationPlayer(forKey: key)?.paused = false
        }
        for child in node.childNodes {
            resumeAllAnimations(in: child)
        }
    }
}
