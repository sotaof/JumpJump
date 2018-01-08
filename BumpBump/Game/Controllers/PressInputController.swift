//
// Created by yang wang on 2017/12/31.
// Copyright (c) 2017 ocean. All rights reserved.
//

import Foundation

@objc
protocol PressInputControllerDelegate {
    func pressInputControllerDidBegin(controller: PressInputController)
    func pressInputControllerUpdating(controller: PressInputController, timeSinceLastUpdate: TimeInterval)
    func pressInputControllerDidEnd(controller: PressInputController, inputFactorBeforeEnd: Float)
}

@objc
class PressInputController: NSObject, ControllerProtocol {
    
    var elapsedTime: TimeInterval = 0
    var inputTotalDuration: TimeInterval = 1.0
    
    public var inputFactor: Float = 0.0
    private var isRunning: Bool = false
    
    public var delegates: HTMulticastDelegate<PressInputControllerDelegate> = HTMulticastDelegate<PressInputControllerDelegate>()
    
    func begin() {
        elapsedTime = 0.0
        inputFactor = 0.0
        isRunning = true
        delegates.invoke { delegate in
            delegate.pressInputControllerDidBegin(controller: self)
        }
    }
    
    func end() {
        delegates.invoke { delegate in
            delegate.pressInputControllerDidEnd(controller: self, inputFactorBeforeEnd: inputFactor)
        }
        inputFactor = 0.0
        isRunning = false
    }
    
    func update(timeSinceLastUpdate: TimeInterval) {
        if isRunning {
            elapsedTime += timeSinceLastUpdate
            inputFactor = Float(elapsedTime / inputTotalDuration)
            inputFactor = inputFactor > 1.0 ? 1.0 : inputFactor
            
            delegates.invoke { delegate in
                delegate.pressInputControllerUpdating(controller: self, timeSinceLastUpdate: timeSinceLastUpdate)
            }
        }
    }
}

