//
// Created by yang wang on 2017/12/30.
// Copyright (c) 2017 ocean. All rights reserved.
//

import SceneKit
import QuartzCore

class BoxController: ControllerProtocol {
    var boxObjects: [BaseBox] = []
    var putPosition: SCNVector3 = SCNVector3.init(0, 0, 0)
    var outsideDistance: Float = 0
    
    let nextBoxDirections = [
        SCNVector3.init(1, 0, 0),
        SCNVector3.init(0, 0, -1),
    ]

    weak var rootNode: SCNNode?

    public var currentBox: BaseBox?
    public var nextBox: BaseBox?
    
    public var hardLevelPercent: Float = 0

    init(rootNode: SCNNode, outsideDistance: Float = 4.0) {
        self.rootNode = rootNode
        self.outsideDistance = outsideDistance
    }

    func reset() {
        clearBoxes()
        putPosition = SCNVector3.init(0, 0, 0)
        currentBox = addBox(direction: nextBoxDirections[0], size: 0.6, distance: 0.0)
        nextBox = addBox(direction: nextBoxDirections[0], size: 0.6, distance: 1.0)
    }

    func clearBoxes() {
        boxObjects.forEach {
            $0.destroy()
        }
        boxObjects = []
    }

    func createNextBox() {
        currentBox = nextBox
        nextBox = addBox()

        // do put box animation
        let originPosition = nextBox!.rootNode().position
        nextBox!.rootNode().position = SCNVector3.init(originPosition.x, originPosition.y + 1.0, originPosition.z)
        let action = SCNAction.move(to: SCNVector3.init(originPosition.x, originPosition.y, originPosition.z), duration: 0.3)
        action.timingMode = .linear
        action.timingFunction = SpringTimingFunction
        nextBox!.rootNode().runAction(action)
    }

    private func addBox(direction: SCNVector3? = nil, size: Float? = nil, distance: Float? = nil) -> BaseBox? {
        if let parentNode = rootNode {
            let newDirectionIndex = Float(arc4random()) / Float(UInt32.max) * Float(nextBoxDirections.count)
            let newDirection = direction ?? nextBoxDirections[Int(newDirectionIndex)]
            let boxSize = size ?? Float(arc4random()) / Float(UInt32.max) * 0.1 + 0.4 - self.hardLevelPercent * 0.25
            let oldBoxHalfSize: Float = self.currentBox != nil ? self.currentBox!.boxSize / 2.0 : Float(0.0)
            let newBoxHalfSize = boxSize / 2.0
            
            let boxDistance: Float = distance ?? Float(arc4random()) / Float(UInt32.max) * 0.5 + oldBoxHalfSize + newBoxHalfSize
            putPosition += newDirection * boxDistance
            
            let newBox = BaseBox.init(geometry: nil, position: putPosition, size: boxSize)
            newBox.addToNode(baseNode: parentNode)
            boxObjects.append(newBox)
            return newBox
        }
        return nil
    }

    func update(timeSinceLastUpdate: TimeInterval) {
        boxObjects.forEach {
            $0.update(timeSinceLastUpdate: timeSinceLastUpdate)
        }
        self.removeBoxOutside()
    }
    
    func removeBoxOutside() {
        if let currentBoxPosition = self.currentBox?.rootNode().position {
            var boxIndex = self.boxObjects.count - 1
            repeat {
                let box = self.boxObjects[boxIndex]
                let deltaPosition = box.rootNode().position - currentBoxPosition
                if deltaPosition.length() > self.outsideDistance {
                    self.boxObjects.remove(at: boxIndex)
                }
                boxIndex -= 1
            } while boxIndex >= 0
        }
    }
}
