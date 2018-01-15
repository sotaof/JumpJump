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
    private var prepareJumpParticleSystem: SCNParticleSystem!
    
    // 运动相关
    private var verticalVelocity: Float = 0
    private var horizontalVelocity: Float = 0
    private var forwardVelocity: Float = 0
    private var verticalVector: SCNVector3 = SCNVector3.init(0, 1, 0)
    private var forwardVector: SCNVector3 = SCNVector3.init(1, 0, 0)

    public var gravity: Float = -40

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
        material.diffuse.contents = UIColor.orange.cgColor
        material.lightingModel = .blinn
        material.ambient.contents = UIColor.orange.cgColor
        
        let body = SCNCone.init(topRadius: 0.04, bottomRadius: 0.065, height: 0.2)
        body.materials = [material]
        let bodyNode = SCNNode.init(geometry: body)
        let head = SCNSphere.init(radius: 0.05)
        head.materials = [material]
        let headNode = SCNNode.init(geometry: head)
        headNode.position = SCNVector3.init(0, 0.17, 0)

        scnNode = SCNNode.init()
        scnNode.addChildNode(bodyNode)
        scnNode.addChildNode(headNode)
        scnNode.pivot = SCNMatrix4MakeTranslation(0, -0.15, 0)
        scnNode.castsShadow = true

        if let particleSystem = SCNParticleSystem.init(named: "prepare", inDirectory: "./") {
            self.prepareJumpParticleSystem = particleSystem
        }
    }

    func prepareJump() {
        if scnNode.particleSystems == nil {
            scnNode.addParticleSystem(self.prepareJumpParticleSystem)
        }
    }

    func jump(beginVelocity: (vertical: Float, horizontal: Float), forward: SCNVector3, groundY: Float) {
        if isOnGround {
            scnNode.removeAllParticleSystems()

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
            
            let halfDuration = abs(beginVelocity.vertical / self.gravity)
            let horizontalHalfVec = forward * beginVelocity.horizontal * halfDuration
            let verticalHalfVec = SCNVector3.init(0, 0.5 * abs(self.gravity) * pow(halfDuration, 2.0), 0.0)
            var currentPosition = self.rootNode().position
            currentPosition.y = self.groundY
            let halfVerticalAction = SCNAction.move(to: currentPosition + verticalHalfVec + horizontalHalfVec, duration: TimeInterval(halfDuration))
            halfVerticalAction.timingMode = .easeOut
            let anotherHalfVerticalAction = SCNAction.move(by: horizontalHalfVec - verticalHalfVec, duration: TimeInterval(halfDuration))
            anotherHalfVerticalAction.timingMode = .easeIn
            let verticalHorizontalAction = SCNAction.sequence([halfVerticalAction, anotherHalfVerticalAction])
            let rotateAxis = self.jumpRotateAxis()
            let rotationAction = SCNAction.rotate(by: CGFloat.pi * 2.0, around: rotateAxis, duration: TimeInterval(halfDuration * 2))
            let finalAction = SCNAction.group([verticalHorizontalAction, rotationAction])
            self.rootNode().runAction(finalAction, completionHandler: {
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
        SCNTransaction.animationDuration = 1.0
        let position = self.scnNode.position
        let minz = (self.rootNode().boundingBox.max - self.rootNode().boundingBox.min).z
        self.scnNode.position = SCNVector3.init(position.x, minz, position.z)
        self.scnNode.rotation = SCNVector4.init(onTopCheckResult.fallRotationAxis.x, onTopCheckResult.fallRotationAxis.y, onTopCheckResult.fallRotationAxis.z,  Float(onTopCheckResult.falldownSide.rawValue) * 90.0 / 180.0 * Float.pi)
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
