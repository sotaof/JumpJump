//
// Created by yang wang on 2017/12/29.
// Copyright (c) 2017 ocean. All rights reserved.
//

import SceneKit
import GLKit

extension SCNVector3 {
    static func *(left: SCNVector3, right: Float) -> SCNVector3 {
        return SCNVector3.init(left.x * right, left.y * right, left.z * right)
    }

    static func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3.init(left.x + right.x, left.y + right.y, left.z + right.z)
    }

    static func -(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3.init(left.x - right.x, left.y - right.y, left.z - right.z)
    }

    static func *(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3.init(left.x * right.x, left.y * right.y, left.z * right.z)
    }

    static func +=(left: inout SCNVector3, right: SCNVector3) {
        left.x += right.x
        left.y += right.y
        left.z += right.z
    }

    static func <(left: SCNVector3, right: SCNVector3) -> Bool {
        return left.x <= right.x && left.y <= right.y && left.z <= right.z
    }

    static func >(left: SCNVector3, right: SCNVector3) -> Bool {
        return !(left < right)
    }

    static func ==(left: SCNVector3, right: SCNVector3) -> Bool {
        return left.x == right.x && left.y == right.y && left.z == right.z
    }
}

extension SCNVector3 {
    func normalize() -> SCNVector3 {
        let glkVec3 = SCNVector3ToGLKVector3(self)
        return SCNVector3FromGLKVector3(GLKVector3Normalize(glkVec3))
    }
    
    func distance(to: SCNVector3) -> Float {
        let fromVec3 = SCNVector3ToGLKVector3(self)
        let toVec3 = SCNVector3ToGLKVector3(to)
        return GLKVector3Distance(fromVec3, toVec3)
    }
    
    func length() -> Float {
        let glkVec3 = SCNVector3ToGLKVector3(self)
        return GLKVector3Length(glkVec3)
    }
}
