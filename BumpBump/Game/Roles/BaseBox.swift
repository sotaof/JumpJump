//
// Created by yang wang on 2017/12/30.
// Copyright (c) 2017 ocean. All rights reserved.
//

import SceneKit

class BaseBox: NSObject, GameObject {
    var geometry: SCNGeometry!
    var scnNode: SCNNode!
    var boxPosition: SCNVector3 = SCNVector3.init(0, 0, 0)
    var boxSize: Float = 0
    let colors: [UIColor] = [
        UIColor.init(rgbHex: 0xeb94ae),
        UIColor.init(rgbHex: 0xf4adad),
        UIColor.init(rgbHex: 0xe4c1f9),
        UIColor.init(rgbHex: 0xd3f8e2),
        UIColor.init(rgbHex: 0xf45b69),
        UIColor.init(rgbHex: 0xBCD8C1),
        UIColor.init(rgbHex: 0xD6DBB2),
        UIColor.init(rgbHex: 0xF76454),
        UIColor.init(rgbHex: 0xE3D985),
    ]
    
    init(geometry: SCNGeometry? = nil, position: SCNVector3? = nil, size: Float? = nil) {
        super.init()
        self.boxPosition = position ?? SCNVector3.init(0, 0, 0)
        self.boxSize = size ?? 1.0
        
        if geometry == nil {
            setupGeometryAndNode()
        } else {
            self.geometry = geometry
        }
    }
    
    deinit {
        self.rootNode().removeFromParentNode()
    }

    func setupGeometryAndNode() {
        let material = SCNMaterial()
        let colorIndex = Float(arc4random()) / Float(UInt32.max) * Float(colors.count - 1)
        material.diffuse.contents = colors[Int(colorIndex)].cgColor

        let geometryType = Float(arc4random()) / Float(UInt32.max)
        if geometryType > 0.5 {
            self.geometry = SCNBox.init(width: CGFloat(self.boxSize), height: 0.3, length: CGFloat(self.boxSize), chamferRadius: 0)
        } else {
            self.geometry = SCNCylinder.init(radius: CGFloat(self.boxSize / 2.0), height: 0.3)
        }
        
        self.geometry.materials = [material]

        self.scnNode = SCNNode.init(geometry: self.geometry)
        self.scnNode.pivot = SCNMatrix4MakeTranslation(0, -0.15, 0)
        self.scnNode.position = self.boxPosition
    }

    func update(timeSinceLastUpdate: TimeInterval) {

    }

    func rootNode() -> SCNNode {
        return self.scnNode
    }

    func topY() -> Float {
        let topY =  geometry.boundingBox.max.y - geometry.boundingBox.min.y + self.scnNode.position.y
        return topY
    }


}
