//
//  LMUControllerTests.swift
//  LightKit
//
//  Created by Max Mouchet on 04/05/15.
//  Copyright (c) 2015 Maxime Mouchet. All rights reserved.
//

import Cocoa
import Darwin
import XCTest
import LightKit

class LMUControllerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetSetDisplayService() {
        let lk = LightKit()!
        
        let expectedBrightness: Float = 0.8
        lk.setDisplayBrightness(0.8)
        
        // Wait for backlight to reach its level
        sleep(1)
        
        if let b = lk.displayBrightness {
            XCTAssertEqualWithAccuracy(b, expectedBrightness, 0.1, "Pass")
        } else {
            XCTFail("Unable to unwrap brightness.")
        }
    }

    func testGetSetKeyboardBrightness() {
        let lk = LightKit()!
        
        let newBrightness = lk.setKeyboardBrightness(0.8)
        let brightness = lk.keyboardBrightness
        
        if let b = brightness, nb = newBrightness {
            XCTAssertEqual(b, nb, "Pass")
        } else {
            XCTFail("Unable to unwrap brightness.")
        }
    }

}
