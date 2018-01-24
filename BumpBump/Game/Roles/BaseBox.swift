//
// Created by yang wang on 2017/12/30.
// Copyright (c) 2017 ocean. All rights reserved.
//

import SceneKit
import ModelIO
import SceneKit.ModelIO

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
//        let colorIndex = Float(arc4random()) / Float(UInt32.max) * Float(colors.count - 1)
        let fileNames = ["bump", "desktop"]//, "cylinder", "box"]
        let diffuseImage = ["base1.png", "base4.png"]//, "base4.png", "base4.png"]
        let geometryType = Int(Float(arc4random()) / Float(UInt32.max) * Float(fileNames.count))
        material.diffuse.contents = UIImage.init(named: diffuseImage[geometryType])

        material.isDoubleSided = true
        self.scnNode = SCNNode.init()
        if let geometryNode = loadNodeFromObjFile(fileName: fileNames[geometryType])  {
            let originSize = geometryNode.boundingBox.max - geometryNode.boundingBox.min
            geometryNode.geometry?.materials = [material]
            geometryNode.scale = SCNVector3.init(self.boxSize / originSize.x, 0.3 / originSize.y, self.boxSize / originSize.z)
            self.geometry = geometryNode.geometry
            self.scnNode.addChildNode(geometryNode)
            self.scnNode.position = self.boxPosition
        }
    }
    
    func loadNodeFromObjFile(fileName: String) -> SCNNode? {
        if let assetUrl = Bundle.main.url(forResource: fileName, withExtension: ".obj") {
            let asset = MDLAsset.init(url: assetUrl)
            return SCNNode.init(mdlObject: asset.object(at: 0))
        }
        return nil
    }
    
    func update(timeSinceLastUpdate: TimeInterval) {
        
    }
    
    func rootNode() -> SCNNode {
        return self.scnNode
    }
    
    func topY() -> Float {
        let topY =  0.3 + self.scnNode.position.y
        return topY
    }
    
    
}

