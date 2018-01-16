//
// Created by yang wang on 2017/12/31.
// Copyright (c) 2017 ocean. All rights reserved.
//

import SceneKit
import UIKit

enum GameState {
    case preparing
    case ready
    case running
    case over
}

@objc
protocol GameDelegate {
    func gameDidStart()
    func gameDidOver()
}

class Game {
    var scene: SCNScene!
    var aspectRatio: Float!
    
    var cameraNode: SCNNode!
    
    var floorNode: SCNNode!
    
    var player: Player!
    
    var gameNode: SCNNode!
    
    var gameState: GameState = .ready
    
    var displayLink: CADisplayLink!
    var lastUpdateTime: TimeInterval = 0
    
    var delegates: HTMulticastDelegate<GameDelegate> = HTMulticastDelegate<GameDelegate>()
    
    // Auto Play for Demo
    var isAutoPlay: Bool = false
    
    // Controllers
    var boxController: BoxController!
    var playerController: PlayerController!
    var cameraController: CameraController!
    var inputController: PressInputController!
    var scoreController: ScoreController!
    
    // Hard Level
    var hardLevel: Int = 0
    
    init(scene: SCNScene, aspectRatio: Float) {
        self.scene = scene
        self.aspectRatio = aspectRatio
        self.gameNode = SCNNode()
        self.scene.rootNode.addChildNode(self.gameNode)
        
        setupCamera()
        setupMainScene()
        
        setupBoxController()
        setupPlayerController()
        setupCameraController()
        setupInputController()
        setupScoreController()
        
        displayLink = CADisplayLink.init(target: self, selector: #selector(update(displayLink:)))
        displayLink.add(to: RunLoop.main, forMode: .commonModes)
    }
    
    func enableAutoPlay() {
        self.playerController.isAutoPlay = true
        self.isAutoPlay = true
    }
    
    func syncAspectRatio(_ aspectRatio: Float) {
        self.aspectRatio = aspectRatio
    }
    
    func setupCamera() {
        self.cameraNode = SCNNode()
        self.cameraNode.camera = SCNCamera()
        let perspectiveMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(38), self.aspectRatio, 0.1, 1000)
        self.cameraNode.camera!.projectionTransform = SCNMatrix4FromGLKMatrix4(perspectiveMatrix)
        scene.rootNode.addChildNode(self.cameraNode)
        
        let lookAtMatrix = GLKMatrix4MakeLookAt(-2.6, 3.8, 3.2, 0, 0, 0, 0, 1, 0)
        let cameraTransform = GLKMatrix4Invert(lookAtMatrix, nil)
        cameraNode.transform = SCNMatrix4FromGLKMatrix4(cameraTransform)
    }
    
    func startGame() {
        // 按照依赖次序配置
        boxController.reset()
        playerController.setupEnvironment(boxController: self.boxController, inputController: self.inputController)
        cameraController.setupTarget(player: self.player, boxController: self.boxController)
        self.gameState = .running
        delegates.invoke { (delegate) in
            delegate.gameDidStart()
        }
    }
    
    func restartGame() {
        scoreController.reset()
        boxController.reset()
        playerController.reset()
        cameraController.reset()
    }
    
    @objc
    func update(displayLink: CADisplayLink) {
        let time = displayLink.timestamp
        if gameState == .running {
            var deltaTime = 0.0
            if lastUpdateTime < 0 {
                lastUpdateTime = time
            } else {
                deltaTime = time - lastUpdateTime
            }
            lastUpdateTime = time
            
            self.update(timeSinceLastUpdate: deltaTime)
        }
    }
    
    func update(timeSinceLastUpdate: TimeInterval) {
        let controllers: [ControllerProtocol] = [inputController, boxController, playerController, cameraController]
        for controller in controllers {
            controller.update(timeSinceLastUpdate: timeSinceLastUpdate)
        }
        
        // tmp code sync floor & player
        let playerPos = player.rootNode().position
        floorNode.position = SCNVector3.init(playerPos.x, floorNode.position.y, playerPos.z)
    }
}

// Setup main scene
extension Game {
    func setupMainScene() {
        createFloor()
        createLight()
        createPlayer()
    }
    
    func createFloor() {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white.cgColor
        material.lightingModel = .constant
        material.writesToDepthBuffer = true
        if #available(iOS 11.0, *) {
            material.colorBufferWriteMask = []
        }
        
        let floor = SCNPlane.init(width: 20, height: 20)
        floor.materials = [material]
        floorNode = SCNNode.init(geometry: floor)
        floorNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
        self.gameNode.addChildNode(floorNode)
        floorNode.castsShadow = true
    }
    
    func createLight() {
        // Main light
        let mainLightNode = SCNNode()
        mainLightNode.light = SCNLight()
        mainLightNode.light?.type = .directional
        mainLightNode.light?.castsShadow = true
        mainLightNode.light?.color = UIColor.init(white: 1.0, alpha: 1.0)
        // 深入了解一下不同的Shadow模式
        // FIXME: 有自阴影的问题
        #if !(arch(i386) || arch(x86_64))
            mainLightNode.light?.shadowMode = .deferred
        #endif
        mainLightNode.light?.shadowColor = UIColor.init(white: 0.0, alpha: 0.15).cgColor
        mainLightNode.rotation = SCNVector4.init(1, -0.4, 0, -Float.pi / 3.3)
        scene.rootNode.addChildNode(mainLightNode)
        
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.init(white: 0.6, alpha: 1.0).cgColor
        scene.rootNode.addChildNode(ambientLightNode)
    }
    
    func createPlayer() {
        player = Player()
        player.addToNode(baseNode: self.gameNode)
    }
}

// Setup Box Controller & Prepare Boxes
extension Game {
    func setupBoxController() {
        self.boxController = BoxController.init(rootNode: self.gameNode)
    }
}

// Setup Camera Controller
extension Game {
    func setupCameraController() {
        self.cameraController = CameraController.init(cameraNode: self.cameraNode)
    }
}

// Player Controller
extension Game: PlayerControllerDelegate {
    func setupPlayerController() {
        self.playerController = PlayerController.init(player: self.player)
        self.playerController.delegates += self
    }
    
    @objc
    func playerControllerLandSuccess(player: Player, box: BaseBox) {
        if let nextBox = self.boxController.nextBox, nextBox === box {
            self.boxController.createNextBox()
            self.cameraController.updateCamera()
            if !self.isAutoPlay {
                self.scoreController.addScore(100)
            }
        }
    }
    
    @objc
    func playerControllerLandFailed(player: Player) {
        self.gameState = .over
        delegates.invoke { (delegate) in
            delegate.gameDidOver()
        }
    }
}

// Input Controller
extension Game {
    func setupInputController() {
        self.inputController = PressInputController()
    }
}

// Score Controller
extension Game: ScoreControllerDelegate {
    func setupScoreController() {
        self.scoreController = ScoreController.init(rootNode: self.gameNode, player: self.player, cameraNode: self.cameraNode)
        self.scoreController.delegates += self
    }
    
    func scoreControllerScoreDidChanged(scoreController: ScoreController, oldScore: Int, newScore: Int) {
        let level = Int(newScore / 150)
        self.hardLevel = level > 10 ? 10 : level
        self.boxController.hardLevelPercent = Float(self.hardLevel) / 10.0
    }
}

