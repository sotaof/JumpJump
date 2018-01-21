//
//  BillboardUtil.swift
//  BumpBump
//
//  Created by ocean on 2018/1/18.
//  Copyright © 2018年 ocean. All rights reserved.
//

import SceneKit
import GLKit

class BillboardUtil {
    class func constraint(source: SCNNode, target: SCNNode) {
        let faceVector = (target.position - source.position).normalize()
        let sourceOriginFaceVector = SCNVector3.init(0, 0, -1)
        let glkFaceVector = SCNVector3ToGLKVector3(faceVector)
        let glkSourceOriginFaceVector = SCNVector3ToGLKVector3(sourceOriginFaceVector)
        let rotateAxis = GLKVector3Normalize(GLKVector3CrossProduct(glkFaceVector, glkSourceOriginFaceVector))
        let rotateAngle = acos(GLKVector3DotProduct(glkFaceVector, glkSourceOriginFaceVector))
        let quaternion = GLKQuaternionMakeWithAngleAndAxis(rotateAngle, rotateAxis.x, rotateAxis.y, rotateAxis.z)
        source.rotation = SCNQuaternion.init(quaternion.x, quaternion.y, quaternion.z, quaternion.w)
    }
}
