//
//  HTMulticastDelegate.swift
//  BumpBump
//
//  Created by yang wang on 2018/1/6.
//  Copyright © 2018年 ocean. All rights reserved.
//

import Foundation

class HTMulticastDelegate<T> where T: AnyObject {
    // TODO: 加锁保护
    private var instances: NSHashTable<T> = NSHashTable<T>.weakObjects()
    func add(instance: T) {
        instances.add(instance)
    }
    
    func invoke(_ invokeBlock: (T) -> Void) {
        for instance in instances.objectEnumerator() {
            if let instanceT = instance as? T {
                invokeBlock(instanceT)
            }
        }
    }
    
    func count()-> Int {
        return instances.count
    }
    
    static func +=(left: HTMulticastDelegate<T>, right: T) {
        left.instances.add(right)
    }
}

