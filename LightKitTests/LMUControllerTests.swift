//
//  LMUControllerTests.swift
//  LightKit
//
//  Created by Max Mouchet on 04/05/15.
//  Copyright (c) 2015 Maxime Mouchet. All rights reserved.
//

import Cocoa
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
        let lmu = LMUController()!
        
        let expectedBrightness: Float = 0.8
        lmu.setDisplayBrightness(0.8)
        
        if let b = lmu.displayBrightness {
            XCTAssertEqual(b, expectedBrightness, "Pass")
        } else {
            XCTFail("Unable to unwrap brightness.")
        }
    }

    func testGetSetKeyboardBrightness() {
        let lmu = LMUController()!
        
        let newBrightness = lmu.setKeyboardBrightness(0.8)
        let brightness = lmu.keyboardBrightness
        
        if let b = brightness, nb = newBrightness {
            XCTAssertEqual(b, nb, "Pass")
        } else {
            XCTFail("Unable to unwrap brightness.")
        }
    }

}
