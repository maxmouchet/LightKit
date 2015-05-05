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

class LightKitTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
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
    
    func testGetSetDisplayBrightness() {
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
    
    func testSetDisplayPower() {
        let lk = LightKit()!
        
        // Put display to sleep
        XCTAssertTrue(lk.setDisplayPower(false), "Pass")
        
        sleep(1)
        
        // Wake up display
        XCTAssertTrue(lk.setDisplayPower(true), "Pass")
    }
    
    func testGetLightSensors() {
        let lk = LightKit()!
        
        if lk.lightSensors == nil {
            XCTFail("Unable to unwrap light sensors.")
        }
    }
}
