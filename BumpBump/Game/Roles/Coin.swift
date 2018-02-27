//
//  Coin.swift
//  BumpBump
//
//  Created by yang wang on 2018/2/27.
//  Copyright © 2018年 ocean. All rights reserved.
//

import SceneKit

class Coin: GameObject {
    
    var scnNode: SCNNode!
    
    init() {
        scnNode = SCNNode.init()
        let geometry  = SCNBox.init(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.02)
        scnNode.geometry = geometry
    }
    
    func rootNode() -> SCNNode {
        return scnNode
    }
    
    func update(timeSinceLastUpdate: TimeInterval) {
        
    }
}
