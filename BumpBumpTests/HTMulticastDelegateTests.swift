//
//  BumpBumpTests.swift
//  BumpBumpTests
//
//  Created by ocean on 2017/12/29.
//  Copyright © 2017年 ocean. All rights reserved.
//

import XCTest
@testable import BumpBump

@objc
protocol TestProtocol {
    
}

class TestTarget: TestProtocol {
    deinit {
        print("Deinit")
    }
}

class BumpBumpTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRepeatPut() {
        let delegates = HTMulticastDelegate<TestProtocol>()
        var target: TestTarget? = TestTarget()
        delegates += target as! TestTarget
        delegates += target as! TestTarget
        var invokeCount = 0
        delegates.invoke { target in
            invokeCount += 1
        }
        XCTAssert(invokeCount == 1, "HTMulticastDelegate重复添加测试")
    }
    
    
}

