//
//  CABlockedAnimation.swift
//  BumpBump
//
//  Created by yang wang on 2018/1/10.
//  Copyright © 2018年 ocean. All rights reserved.
//

import UIKit
import ObjectiveC

extension CAAnimation: CAAnimationDelegate {
    private struct CABlockedAnimationKeys {
        static var kCompletedBlock: String = ""
    }
    
    var completedBlock: ((Bool) -> Void)? {
        set(value) {
            objc_setAssociatedObject(self, &CABlockedAnimationKeys.kCompletedBlock, value, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &CABlockedAnimationKeys.kCompletedBlock) as? (Bool) -> Void
        }
    }
    
    func addToLayer(layer: CALayer, key: String, completed: @escaping (Bool) -> Void) {
        self.delegate = self
        self.completedBlock = completed
        layer.add(self, forKey: key)
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let completedBlock = self.completedBlock {
            completedBlock(flag)
            self.completedBlock = nil
        }
    }
}
