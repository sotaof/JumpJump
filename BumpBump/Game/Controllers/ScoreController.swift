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

class ScoreController {
    var scene: SCNScene!
    var player: Player!
    
    public var score: Int = 0
    init(scene: SCNScene, player: Player) {
        self.scene = scene
        self.player = player
    }
    
    func addScore(_ scoreAdded: Int) {
        score += scoreAdded

        doAddScoreEffect(scoreAdded: scoreAdded)
    }
    
    func doAddScoreEffect(scoreAdded: Int) {
        let effectNode = SCNNode()
        let geometry = SCNPlane.init(width: 0.2, height: 0.2)
        let material = SCNMaterial()
        let numberImage = StringImageGenerator.createImage(string: "+\(scoreAdded)", foregroundColor: UIColor.black, backgroundColor: UIColor.clear, size: CGSize.init(width: 100, height: 100))
        
        material.diffuse.contents = numberImage
        material.blendMode = .alpha
        
        geometry.materials = [material]
        effectNode.geometry = geometry
        self.scene.rootNode.addChildNode(effectNode)
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = .all
        effectNode.constraints = [billboardConstraint]
        effectNode.position = self.player.rootNode().position + SCNVector3.init(0, 0.1, 0)
        
        let riseAnimation = SCNAction.move(by: SCNVector3.init(0, 1.0, 0), duration: 0.6)
        let fadeAnimation = SCNAction.fadeOut(duration: 0.6)
        let riseFadeAnimation = SCNAction.group([riseAnimation, fadeAnimation])
        effectNode.runAction(riseFadeAnimation) {
            effectNode.removeFromParentNode()
        }
    }
    
    func reset() {
        self.score = 0
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
