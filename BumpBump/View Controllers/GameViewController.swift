//
//  GameViewController.swift
//  BumpBump
//
//  Created by ocean on 2017/12/29.
//  Copyright © 2017年 ocean. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import SceneKit
import GLKit
import ARKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {
    
    var scene: SCNScene!
    
    var lastUpdateTime: TimeInterval = -1
    
    var game: Game!
    @IBOutlet weak var scoreLabel: ScoreCard!
    @IBOutlet weak var newRecordLabel: UILabel!
    @IBOutlet weak var gameOverPanel: UIView!
    
    var isGameStarted: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        gameOverPanel.isHidden = true
        
        scene = SCNScene()
        
        let scnView = self.view as! SCNView
        scnView.scene = scene
        scnView.delegate = self
        scnView.backgroundColor = UIColor.lightGray
        scene.rootNode.castsShadow = true
        if #available(iOS 10.0, *) {
            scnView.rendersContinuously = true
        }
        game = Game.init(scene: scene, aspectRatio: Float(self.view.frame.size.width /  self.view.frame.size.height))
        game.startGame()
        setupScoreController()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if game.gameState == .running {
            game.inputController.begin()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if game.gameState == .running {
            game.inputController.end()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if game.gameState == .running {
            var deltaTime = 0.0
            if lastUpdateTime < 0 {
                lastUpdateTime = time
            } else {
                deltaTime = time - lastUpdateTime
            }
            lastUpdateTime = time
            
            game.update(timeSinceLastUpdate: deltaTime)
        } else if game.gameState == .over {
            self.game.gameState = .preparing
            DispatchQueue.main.async {
                self.gameOverPanel.isHidden = false
                if self.game.scoreController.isNewRecord() {
                    self.newRecordLabel.isHidden = false
                } else {
                    self.newRecordLabel.isHidden = true
                }
                self.game.scoreController.saveScore()
            }
        }
    }
    
    @IBAction func continueGameButtonTapped(button: UIButton) {
        gameOverPanel.isHidden = true
        
        if game.gameState == .preparing {
            game.restartGame()
            game.gameState = .running
        }
    }
}

extension GameViewController: ScoreControllerDelegate {
    func setupScoreController() {
        game.scoreController.delegates += self
        game.scoreController.reset()
    }
    
    func scoreControllerScoreDidChanged(scoreController: ScoreController, oldScore: Int, newScore: Int) {
        DispatchQueue.main.async {
            self.scoreLabel.setScore(score: newScore)
        }
    }
}

//extension GameViewController: ARSCNViewDelegate {
//    
//    func startAR() {
//        // Create a session configuration
//        let configuration = ARWorldTrackingConfiguration()
//        configuration.planeDetection = .horizontal
//        let sceneView = self.view as! ARSCNView
//        // Run the view's session
//        sceneView.session.run(configuration)
//    }
//    
//    // Override to create and configure nodes for anchors added to the view's session.
//    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
////        let node = SCNNode()
////        node.geometry = SCNBox.init(width: 0.1, height: 0.001, length: 0.1, chamferRadius: 0)
////        node.transform = SCNMatrix4(anchor.transform)
//        game.gameNode.transform = SCNMatrix4Mult(SCNMatrix4MakeScale(0.2, 0.2, 0.2), SCNMatrix4(anchor.transform))
//        return nil
//    }
//    
//    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
////        node.transform = SCNMatrix4(anchor.transform)
//        game.gameNode.transform = SCNMatrix4Mult(SCNMatrix4MakeScale(0.2, 0.2, 0.2), SCNMatrix4(anchor.transform))
//    }
//    
//    func session(_ session: ARSession, didFailWithError error: Error) {
//        // Present an error message to the user
//        
//    }
//    
//    func sessionWasInterrupted(_ session: ARSession) {
//        // Inform the user that the session has been interrupted, for example, by presenting an overlay
//        
//    }
//    
//    func sessionInterruptionEnded(_ session: ARSession) {
//        // Reset tracking and/or remove existing anchors if consistent tracking is required
//        
//    }
//    
//    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
//        print(camera.trackingState)
//    }
//}

