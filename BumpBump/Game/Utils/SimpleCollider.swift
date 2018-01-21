//
// Created by yang wang on 2017/12/30.
// Copyright (c) 2017 ocean. All rights reserved.
//

import SceneKit
import GLKit

protocol SimpleCollider {
    func isOnTheTopOfCollider(bottomOne: SimpleCollider) -> Bool
}

enum FallDownSide: Int {
    case forward = 1
    case backward = -1
    case sideward = 0
}

struct OnTopCheckResult {
    var isOnTop: Bool
    var falldownSide: FallDownSide
    var fallRotationAxis: SCNVector3
    var distance: Float
}

struct BoxCollider {

    private var boundingBoxMax: SCNVector3!
    private var boundingBoxMin: SCNVector3!

    init(boundingBoxMin: SCNVector3, boundingBoxMax: SCNVector3) {
        self.boundingBoxMin = boundingBoxMin
        self.boundingBoxMax = boundingBoxMax
    }

    func bottomCenterPoint() -> SCNVector3 {
        var center = (self.boundingBoxMin + self.boundingBoxMax) * 0.5
        center.y = self.boundingBoxMin.y
        return center
    }

    func topCenterPoint() -> SCNVector3 {
        var center = (self.boundingBoxMin + self.boundingBoxMax) * 0.5
        center.y = self.boundingBoxMax.y
        return center
    }

    func isOnTheTopOfCollider(bottomOne: BoxCollider, result: inout OnTopCheckResult, forwardVector: SCNVector3) -> Bool {
        let topOneBottomCenter = bottomCenterPoint()
        if topOneBottomCenter.x >= bottomOne.boundingBoxMin.x
                   && topOneBottomCenter.x <= bottomOne.boundingBoxMax.x
                   && topOneBottomCenter.z >= bottomOne.boundingBoxMin.z
                   && topOneBottomCenter.z <= bottomOne.boundingBoxMax.z {
            result.isOnTop = true
            return true
        } else {
            result.isOnTop = false
            let bottomWidth: CGFloat = CGFloat(bottomOne.boundingBoxMax.x - bottomOne.boundingBoxMin.x)
            let bottomHeight: CGFloat = CGFloat(bottomOne.boundingBoxMax.z - bottomOne.boundingBoxMin.z)
            let bottomRect: CGRect = CGRect.init(x: CGFloat(bottomOne.boundingBoxMin.x), y: CGFloat(bottomOne.boundingBoxMin.z), width: bottomWidth, height: bottomHeight)
            let topWidth = CGFloat(self.boundingBoxMax.x - self.boundingBoxMin.x)
            let topHeight = CGFloat(self.boundingBoxMax.z - self.boundingBoxMin.z)
            let topRect: CGRect = CGRect.init(x: CGFloat(self.boundingBoxMin.x), y: CGFloat(self.boundingBoxMin.z), width: topWidth, height: topHeight)
            
            if topRect.intersects(bottomRect) == false {
                result.falldownSide = .sideward
                result.fallRotationAxis = forwardVector.normalize()
            } else {
                let bottomOneTopCenter = bottomOne.topCenterPoint()
                var bottomOneTopToTopOneBottomVec = topOneBottomCenter - bottomOneTopCenter
                bottomOneTopToTopOneBottomVec = bottomOneTopToTopOneBottomVec.normalize()
                if GLKVector3DotProduct(SCNVector3ToGLKVector3(bottomOneTopToTopOneBottomVec), SCNVector3ToGLKVector3(forwardVector.normalize())) <= 0 {
                    result.falldownSide = .backward
                } else {
                    result.falldownSide = .forward
                }
                
                let rotationAroundY = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(90), 0, 1, 0)
                result.fallRotationAxis = SCNVector3FromGLKVector3(GLKQuaternionRotateVector3(rotationAroundY, SCNVector3ToGLKVector3(forwardVector.normalize())))
                result.distance = GLKVector3Distance(SCNVector3ToGLKVector3(topOneBottomCenter), SCNVector3ToGLKVector3(bottomOne.topCenterPoint()))
            }
        }
        return false
    }

    static func fromSCNNode(scnNode: SCNNode) -> BoxCollider {
        let min = scnNode.boundingBox.min + scnNode.position
        let max = scnNode.boundingBox.max + scnNode.position
        var collider = BoxCollider(boundingBoxMin: min, boundingBoxMax: max)
        return collider
    }
}
