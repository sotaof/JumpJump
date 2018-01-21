//
// Created by yang wang on 2017/12/31.
// Copyright (c) 2017 ocean. All rights reserved.
//

import SceneKit

@objc
protocol PlayerControllerDelegate {
    func playerControllerLandSuccess(player: Player, box: BaseBox)
    func playerControllerLandFailed(player: Player)
}

class PlayerController: ControllerProtocol {
    var boxController: BoxController!
    var inputController: PressInputController!
    var player: Player!
    
    var delegates: HTMulticastDelegate<PlayerControllerDelegate> = HTMulticastDelegate<PlayerControllerDelegate>()
    // Auto Play
    public var isAutoPlay: Bool = false
    
    init(player: Player) {
        self.player = player
        self.player.delegates += self
    }
    
    func setupEnvironment(boxController: BoxController, inputController: PressInputController) {
        self.boxController = boxController
        self.inputController = inputController
        self.reset()
        inputController.delegates += self
    }
    
    func reset() {
        self.player.groundY = boxController.currentBox?.topY() ?? 0
        self.player.reset()
    }
    
    func update(timeSinceLastUpdate: TimeInterval) {
        player.update(timeSinceLastUpdate: timeSinceLastUpdate)
    }
    
    // MARK: Private Methods
    private func jumpForwardVector() -> SCNVector3 {
        if let nextBox = self.boxController.nextBox {
            var forwardVec = nextBox.rootNode().position - self.player.rootNode().position
            forwardVec.y = 0
            return forwardVec.normalize()
        }
        return SCNVector3.init(1, 0, 0)
    }
    
    private func jumpDistance() -> Float {
        if let nextBox = self.boxController.nextBox {
            var forwardVec = nextBox.rootNode().position - self.player.rootNode().position
            forwardVec.y = 0
            return forwardVec.length()
        }
        return 0
    }
}

extension PlayerController: PressInputControllerDelegate {
    func pressInputControllerDidBegin(controller: PressInputController) {
        player.prepareJump()
    }
    
    func pressInputControllerUpdating(controller: PressInputController, timeSinceLastUpdate: TimeInterval) {
        if player.isOnGround {
            let scaleFactor: Float = 1.0 - inputController.inputFactor * 0.5
            player.rootNode().scale = SCNVector3.init(1 + inputController.inputFactor * 0.5, scaleFactor, 1 + inputController.inputFactor * 0.5)
            var originPos = player.rootNode().position
            originPos.y = player.groundY * scaleFactor
            player.rootNode().position = originPos
            
            boxController.currentBox?.rootNode().scale = SCNVector3.init(1, scaleFactor, 1)
        }
    }
    
    func pressInputControllerDidEnd(controller: PressInputController, inputFactorBeforeEnd: Float) {
        let initialScale = boxController.currentBox?.rootNode().scale
        let duration = 0.25
        let boxRecoverAction = SCNAction.customAction(duration: duration) { (node, time) in
            let percent = Float(time) / Float(duration)
            node.scale = SCNVector3.init(1, (1.0 - initialScale!.y) * percent + initialScale!.y, 1.0)
        }
        boxRecoverAction.timingMode = .linear
        boxRecoverAction.timingFunction = SpringTimingFunction
        boxController.currentBox?.rootNode().runAction(boxRecoverAction)
        player.rootNode().scale = SCNVector3.init(1, 1.0, 1)
        
        let newGroundY = self.boxController.nextBox?.topY() ?? 0
        self.player.jump(beginVelocity: (vertical: 8.0, horizontal: 6.0 * inputFactorBeforeEnd), forward: jumpForwardVector(), groundY: newGroundY)
    }
    
}

extension PlayerController: PlayerDelegate {
    func playerDidLand() {
        self.checkPlayerCollisionWithBox()
        if player.state == .landSuccess {
            let forward = self.jumpForwardVector()
            self.player.faceTo(forward: forward)
            if isAutoPlay {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    let newGroundY = self.boxController.nextBox?.topY() ?? 0
                    let jumpTime: Float = self.player.timeInSky(verticalInitVelocity: 8)
                    let distance: Float = self.jumpDistance()
                    self.player.jump(beginVelocity: (vertical: 8, horizontal: Float(distance / jumpTime)), forward: self.jumpForwardVector(), groundY: newGroundY)
                })
            }
        }
    }
    
    func playerWillJump() {
        
    }
    
    func checkPlayerCollisionWithBox() {
        let playerCollider = BoxCollider.fromSCNNode(scnNode: player.rootNode())
        var onTopCheckResult: OnTopCheckResult? = nil
        for box in self.boxController.boxObjects {
            let boxCollider = BoxCollider.fromSCNNode(scnNode: box.rootNode())
            if self.player.isOnGround {
                var checkResult: OnTopCheckResult = OnTopCheckResult(isOnTop: false, falldownSide: .forward, fallRotationAxis: SCNVector3Zero, distance: 0)
                if playerCollider.isOnTheTopOfCollider(bottomOne: boxCollider, result: &checkResult, forwardVector: player.jumpForwardVector) == false {
                    if onTopCheckResult == nil {
                        onTopCheckResult = checkResult
                    } else if checkResult.distance < onTopCheckResult!.distance {
                        onTopCheckResult = checkResult
                    }
                } else {
                    self.player.state = .landSuccess
                    delegates.invoke({ delegate in
                        delegate.playerControllerLandSuccess(player: self.player, box: box)
                    })
                    onTopCheckResult = nil
                    break
                }
            }
        }
        if onTopCheckResult != nil {
            self.player.falldown(onTopCheckResult: onTopCheckResult!)
            self.player.state = .landFailed
            delegates.invoke({ delegate in
                delegate.playerControllerLandFailed(player: self.player)
            })
        }
    }
}

