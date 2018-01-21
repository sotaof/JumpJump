//
//  ScoreController.swift
//  BumpBump
//
//  Created by yang wang on 2018/1/2.
//  Copyright © 2018年 ocean. All rights reserved.
//

import SceneKit
import SpriteKit

let kScoreSaveKey = "kScoreSaveKey"

@objc
protocol ScoreControllerDelegate {
    func scoreControllerScoreDidChanged(scoreController: ScoreController, oldScore: Int, newScore: Int)
}

@objc
class ScoreController: NSObject {
    var rootNode: SCNNode!
    var player: Player!
    var newRecordParticleSystem: SCNParticleSystem!
    var cameraNode: SCNNode!
    
    private var isNewRecordTriggered: Bool = false
    
    var delegates: HTMulticastDelegate<ScoreControllerDelegate> = HTMulticastDelegate<ScoreControllerDelegate>()
    
    public var score: Int = 0
    init(rootNode: SCNNode, player: Player, cameraNode: SCNNode) {
        self.rootNode = rootNode
        self.player = player
        self.cameraNode = cameraNode
        
        newRecordParticleSystem = SCNParticleSystem.init(named: "newrecord", inDirectory: "./")
    }
    
    func addScore(_ scoreAdded: Int) {
        self.delegates.invoke { delegate in
            delegate.scoreControllerScoreDidChanged(scoreController: self, oldScore: score, newScore: score + scoreAdded)
        }
        self.score += scoreAdded
        doAddScoreEffect(scoreAdded: scoreAdded)
        
        if isNewRecord() && !isNewRecordTriggered {
            doNewRecordEffect()
            isNewRecordTriggered = true
        }
    }
    
    func doAddScoreEffect(scoreAdded: Int) {
        let effectNode = SCNNode()
        let geometry = SCNPlane.init(width: 0.22, height: 0.22)
        let material = SCNMaterial()
        let numberImage = StringImageGenerator.createImage(string: "+\(scoreAdded)", foregroundColor: UIColor.black, backgroundColor: UIColor.clear, size: CGSize.init(width: 100, height: 100))
        
        material.diffuse.contents = numberImage
        material.blendMode = .alpha
        
        geometry.materials = [material]
        effectNode.geometry = geometry
        rootNode.addChildNode(effectNode)
        effectNode.position = self.player.rootNode().position + SCNVector3.init(0, 0.1, 0)
        
        let riseAnimation = SCNAction.move(by: SCNVector3.init(0, 0.6, 0), duration: 0.6)
        let fadeAnimation = SCNAction.fadeOut(duration: 0.6)
        let riseFadeAnimation = SCNAction.group([riseAnimation, fadeAnimation])
        let billbordConstraint = SCNBillboardConstraint()
        effectNode.constraints = [billbordConstraint]
        effectNode.runAction(riseFadeAnimation) {
            effectNode.removeFromParentNode()
        }
    }
    
    func doNewRecordEffect() {
        let effectNode = SCNNode()
        let geometry = SCNPlane.init(width: 1.0, height: 1.0)
        let material = SCNMaterial()
        let numberImage = StringImageGenerator.createImage(string: "New Record", foregroundColor: UIColor.orange, backgroundColor: UIColor.clear, size: CGSize.init(width: 500, height: 500))
        
        material.diffuse.contents = numberImage
        material.blendMode = .alpha
        
        geometry.materials = [material]
        effectNode.geometry = geometry
        rootNode.addChildNode(effectNode)
        effectNode.position = self.player.rootNode().position + SCNVector3.init(0, 0.1, 0)
        
        let riseAnimation = SCNAction.move(by: SCNVector3.init(0, 1.0, 0), duration: 0.4)
        let fadeAnimation = SCNAction.fadeOut(duration: 1.0)
        let riseFadeAnimation = SCNAction.group([riseAnimation, fadeAnimation])
        let billbordConstraint = SCNBillboardConstraint()
        effectNode.constraints = [billbordConstraint]
        effectNode.runAction(riseFadeAnimation) {
            effectNode.removeFromParentNode()
        }
        
        player.rootNode().addParticleSystem(newRecordParticleSystem)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.player.rootNode().removeParticleSystem(self.newRecordParticleSystem)
        }
    }
    
    func reset() {
        self.delegates.invoke { delegate in
            delegate.scoreControllerScoreDidChanged(scoreController: self, oldScore: score, newScore: 0)
        }
        self.score = 0
        self.isNewRecordTriggered = false
    }
    
    func saveScore() {
        var needSaveScore = true
        if let oldScore = UserDefaults.standard.value(forKey: kScoreSaveKey) as? Int, self.score < oldScore {
            needSaveScore = false
        }
        if needSaveScore {
            UserDefaults.standard.set(self.score, forKey: kScoreSaveKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    func isNewRecord() -> Bool {
        if let oldScore = UserDefaults.standard.value(forKey: kScoreSaveKey) as? Int {
            return self.score > oldScore
        }
        return true
    }
}
