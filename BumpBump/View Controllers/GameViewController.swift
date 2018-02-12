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

class GameViewController: UIViewController, SCNSceneRendererDelegate, GameDelegate {
    
    var scene: SCNScene!
    var bgLayer: CAGradientLayer!
    
    var lastUpdateTime: TimeInterval = -1
    
    var game: Game!
    @IBOutlet weak var scoreLabel: ScoreCard!
    @IBOutlet weak var scnView: SCNView!
    @IBOutlet weak var gameOverPanel: RestartPanel!
    
    var isGameStarted: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        gameOverPanel.isHidden = true
        
        scene = SCNScene()
        
        scnView.scene = scene
        scnView.delegate = self
        scnView.backgroundColor = UIColor.white
        
        bgLayer = CAGradientLayer()
        bgLayer.frame = self.view.bounds
        
        scene.rootNode.castsShadow = true
        scene.background.contents = bgLayer
        game = Game.init(scene: scene, aspectRatio: Float(self.view.frame.size.width /  self.view.frame.size.height))
        game.delegates += self
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
    
    @IBAction func rankListTapped(_ sender: Any) {
        GameCenterManager.showRankList()
    }
    
    @IBAction func continueGameButtonTapped(button: UIButton) {
        self.gameOverPanel.hide()
        
        if game.gameState == .preparing {
            game.restartGame()
            game.gameState = .running
        }
    }
    
    func gameDidStart() {
        self.scoreLabel.isHidden = false
    }
    
    func gameDidOver() {
        self.game.gameState = .preparing
        DispatchQueue.main.async {
            self.gameOverPanel.show()
            self.gameOverPanel.finalScoreLabel.text = "\(self.game.scoreController.score)"
            if self.game.scoreController.isNewRecord() {
                GameCenterManager.reportScore(scoreValue: self.game.scoreController.score) { error in
                    
                }
                self.gameOverPanel.newRecordView.isHidden = false
                self.gameOverPanel.finalScoreIconView.isHidden = true
            } else {
                self.gameOverPanel.newRecordView.isHidden = true
                self.gameOverPanel.finalScoreIconView.isHidden = false
            }
            self.scoreLabel.isHidden = true
            self.game.scoreController.saveScore()
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
            if newScore % 15 == 0 {
                UIView.animate(withDuration: 2, animations: {
                    let hue = CGFloat(arc4random()) / CGFloat(UInt32.max)
                    self.bgLayer.colors = [
                        UIColor.init(hue: hue, saturation: 0.14, brightness: 0.85, alpha: 1.0).cgColor,
                        UIColor.init(hue: hue, saturation: 0.07, brightness: 1.0, alpha: 1.0).cgColor,
                    ]
                })
            }
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

