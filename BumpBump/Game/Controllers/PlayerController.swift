//
// Created by yang wang on 2017/12/31.
// Copyright (c) 2017 ocean. All rights reserved.
//

import SceneKit

class PlayerController: ControllerProtocol {
    var boxController: BoxController!
    var inputController: PressInputController!
    var player: Player!

    init(player: Player) {
        self.player = player
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
        boxController.currentBox?.rootNode().scale = SCNVector3.init(1, 1.0, 1)
        
        let newGroundY = self.boxController.nextBox?.topY() ?? 0
        self.player.jump(beginVelocity: (vertical: 7, horizontal: 8.0 * inputFactorBeforeEnd), forward: jumpForwardVector(), groundY: newGroundY)
    }
    
}
