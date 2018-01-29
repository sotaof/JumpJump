//
// Created by yang wang on 2017/12/29.
// Copyright (c) 2017 ocean. All rights reserved.
//

import SceneKit
import GLKit
import UIKit

enum PlayerState: Int {
    case idle
    case jumping
    case landSuccess
    case landFailed
}

@objc
protocol PlayerDelegate {
    func playerWillJump()
    func playerDidLand()
}

@objc
class Player: NSObject, GameObject {
    public var delegates: HTMulticastDelegate<PlayerDelegate> = HTMulticastDelegate<PlayerDelegate>()
    
    private var scnNode: SCNNode!
    private var playerRootNode: SCNNode!
    private var playerArmNodes: [SCNNode] = [SCNNode]()
    private var prepareJumpParticleSystem: SCNParticleSystem!
    
    // 运动相关
    private var verticalVelocity: Float = 0
    private var horizontalVelocity: Float = 0
    private var forwardVelocity: Float = 0
    private var verticalVector: SCNVector3 = SCNVector3.init(0, 1, 0)
    private var forwardVector: SCNVector3 = SCNVector3.init(1, 0, 0)
    
    public var gravity: Float = -35
    
    // 跳跃相关
    private var jumpingRotation: Float = 0
    private var beginJumpVelocity: Float = 0
    public var jumpForwardVector: SCNVector3 = SCNVector3.init(0, 0, 0)
    // 不想使用物理引擎，此处通过跳跃时传入下一个Box的顶部Y来确定何时结束跳跃
    public var groundY: Float = 0
    
    // 状态管理
    public var isOnGround: Bool = false
    public var state: PlayerState = .idle
    
    override init() {
        super.init()
        setupGeometryAndNode()
    }
    
    convenience init(groundY: Float) {
        self.init()
        self.groundY = groundY
    }
    
    func setupGeometryAndNode() {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.init(rgbHex: 0x5edbf5).cgColor
        material.lightingModel = .lambert
        material.ambient.contents = UIColor.init(rgbHex: 0x5edbf5).cgColor
        
        let head = SCNBox.init(width: 0.08, height: 0.08, length: 0.08, chamferRadius: 0)
        let headNode = SCNNode.init(geometry: head)
        headNode.position = SCNVector3.init(0, 0.17, 0)
        head.materials = [material]
        
        
        let body = SCNBox.init(width: 0.1, height: 0.15, length: 0.1, chamferRadius: 0) // SCNCylinder.init(radius: 0.05, height: 0.15)// SCNSphere.init(width: 0.1, height: 0.15, length: 0.1, chamferRadius: 0)
//        body.radialSegmentCount = 4
        let bodyNode = SCNNode.init(geometry: body)
        bodyNode.position = SCNVector3.init(0, 0, 0)
        body.materials = [material]
        
        let leftArm = SCNCone.init(topRadius: 0.02, bottomRadius: 0.005, height: 0.09) //SCNCylinder.init(radius: 0.02, height: 0.09) //SCNBox.init(width: 0.04, height: 0.09, length: 0.04, chamferRadius: 0)
        leftArm.radialSegmentCount = 3
        let leftArmNode = SCNNode.init(geometry: leftArm)
        leftArmNode.position = SCNVector3.init(-0.09, 0.045, 0)
        leftArmNode.pivot = SCNMatrix4MakeTranslation(0, 0.045, 0)
        leftArm.materials = [material]
        
        let rightArm = SCNCone.init(topRadius: 0.02, bottomRadius: 0.005, height: 0.09) //SCNCylinder.init(radius: 0.02, height: 0.09)//SCNBox.init(width: 0.04, height: 0.09, length: 0.04, chamferRadius: 0)
        rightArm.radialSegmentCount = 3
        let rightArmNode = SCNNode.init(geometry: rightArm)
        rightArmNode.position = SCNVector3.init(0.09, 0.045, 0)
        rightArmNode.pivot = SCNMatrix4MakeTranslation(0, 0.045, 0)
        rightArm.materials = [material]
        
        playerArmNodes = [leftArmNode, rightArmNode]
        
        playerRootNode = SCNNode.init()
        playerRootNode.addChildNode(bodyNode)
        playerRootNode.addChildNode(headNode)
        playerRootNode.addChildNode(leftArmNode)
        playerRootNode.addChildNode(rightArmNode)
        
        scnNode = SCNNode.init()
        scnNode.addChildNode(playerRootNode)
        scnNode.pivot = SCNMatrix4MakeTranslation(0, -0.15, 0)
        scnNode.castsShadow = true
        
        if let particleSystem = SCNParticleSystem.init(named: "prepare", inDirectory: "./") {
            self.prepareJumpParticleSystem = particleSystem
        }
    }
    
    func faceTo(forward: SCNVector3) {
        let defaultForward = SCNVector3ToGLKVector3(SCNVector3.init(0, 0, -1))
        let forwardProject = SCNVector3ToGLKVector3(SCNVector3.init(forward.x, 0, forward.z).normalize())
        let angle = acos(GLKVector3DotProduct(defaultForward, forwardProject))
        let rotateAxis = GLKVector3CrossProduct(defaultForward, forwardProject)
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.2
        playerRootNode.rotation = SCNVector4.init(rotateAxis.x, rotateAxis.y, rotateAxis.z, angle)
        SCNTransaction.commit()
    }
    
    func prepareJump() {
        if scnNode.particleSystems == nil {
            scnNode.addParticleSystem(self.prepareJumpParticleSystem)
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.2
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)
            for arm in playerArmNodes {
                arm.rotation = SCNVector4.init(1, 0, 0, -Float.pi / 4.0)
            }
            SCNTransaction.commit()
        }
    }
    
    func jump(beginVelocity: (vertical: Float, horizontal: Float), forward: SCNVector3, groundY: Float) {
        if isOnGround {
            scnNode.removeAllParticleSystems()
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.2
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)
            for arm in playerArmNodes {
                arm.rotation = SCNVector4.init(1, 0, 0, 0)
            }
            SCNTransaction.commit()
            
            self.delegates.invoke({ delegate in
                delegate.playerWillJump()
            })
            
            self.beginJumpVelocity = beginVelocity.vertical
            self.verticalVelocity = beginVelocity.vertical
            self.horizontalVelocity = beginVelocity.horizontal
            self.jumpForwardVector = forward
            self.jumpingRotation = 0
            self.groundY = groundY
            self.isOnGround = false
            self.state = .jumping
            
            let halfDuration = TimeInterval(abs(beginVelocity.vertical / self.gravity))
            let playerStartPosition = self.rootNode().position
            let rotateAxis = self.jumpRotateAxis()
            let jumpAction = SCNAction.customAction(duration: halfDuration * 2, action: { (node, time) in
                var newPosition = playerStartPosition + forward * beginVelocity.horizontal * Float(time)
                let verticalOffset = beginVelocity.vertical * Float(time)  + 0.5 * self.gravity * pow(Float(time), 2)
                newPosition += SCNVector3.init(0, verticalOffset, 0.0)
                if TimeInterval(time) >= halfDuration * 2 {
                    newPosition.y = groundY
                }
                node.position = newPosition
                node.rotation = SCNVector4.init(rotateAxis.x, rotateAxis.y, rotateAxis.z, Float.pi * Float(time) / Float(halfDuration))
            })
            self.rootNode().runAction(jumpAction, completionHandler: {
                self.isOnGround = true
                self.delegates.invoke({ delegate in
                    delegate.playerDidLand()
                })
            })
        }
    }
    
    func land() {
        if !isOnGround {
            let moveDistance = self.groundY - self.rootNode().position.y
            let landAction = SCNAction.move(by: SCNVector3.init(0, moveDistance, 0), duration: 0.3)
            landAction.timingMode = .linear
            landAction.timingFunction = SpringTimingFunction
            self.rootNode().runAction(landAction, completionHandler: {
                self.isOnGround = true
                self.delegates.invoke({ delegate in
                    delegate.playerDidLand()
                })
            })
        }
    }
    
    func falldown(onTopCheckResult: OnTopCheckResult) {
        self.scnNode.rotation = SCNVector4.init(onTopCheckResult.fallRotationAxis.x, onTopCheckResult.fallRotationAxis.y, onTopCheckResult.fallRotationAxis.z, 0)
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        let position = self.scnNode.position
        let minz = (self.rootNode().boundingBox.max - self.rootNode().boundingBox.min).z
        self.scnNode.position = SCNVector3.init(position.x, minz, position.z)
        if onTopCheckResult.falldownSide != .sideward {
            self.scnNode.rotation = SCNVector4.init(onTopCheckResult.fallRotationAxis.x, onTopCheckResult.fallRotationAxis.y, onTopCheckResult.fallRotationAxis.z,  Float(onTopCheckResult.falldownSide.rawValue) * 90.0 / 180.0 * Float.pi)
        } else {
            self.scnNode.rotation = SCNVector4.init(onTopCheckResult.fallRotationAxis.x, onTopCheckResult.fallRotationAxis.y, onTopCheckResult.fallRotationAxis.z, 90.0 / 180.0 * Float.pi)
        }
        SCNTransaction.commit()
    }
    
    func reset() {
        verticalVelocity = 0
        horizontalVelocity = 0
        beginJumpVelocity = 0
        self.scnNode.position = SCNVector3.init(0.0 , self.groundY + 1.0, 0.0)
        self.scnNode.rotation = SCNVector4.init(0, 0, 1, 0)
        self.isOnGround = false
        self.land()
    }
    
    private func jumpRotateAxis() -> SCNVector3 {
        // 目前跳跃旋转轴只会在xz平面上，所以将跳跃方向的向量围绕y轴旋转90度就能得到跳跃旋转轴
        let glkForwardAxis = SCNVector3ToGLKVector3(jumpForwardVector)
        let forwardAxisRotation = GLKQuaternionMakeWithAngleAndAxis(Float.pi / 2.0, 0, 1, 0)
        let rotateAxis = GLKQuaternionRotateVector3(forwardAxisRotation, glkForwardAxis)
        return SCNVector3FromGLKVector3(rotateAxis)
    }
    
    func update(timeSinceLastUpdate: TimeInterval) {
    }
    
    func rootNode() -> SCNNode {
        return self.scnNode
    }
    
    func timeInSky(verticalInitVelocity: Float) -> Float {
        return fabs(verticalInitVelocity / gravity * 2.0)
    }
}

