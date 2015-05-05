//
//  LightKit.swift
//  LightKit
//
//  Created by Max Mouchet on 04/05/15.
//
//  Ported from https://github.com/samnung/maclight/
//  See licence below.
//

//
//  Copyright (c) 2013, samnung
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.

//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
//  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import IOKit
import CoreGraphics

public class LMUController {
    private var dataPort: io_connect_t = 0
    
    private let kGetSensorReadingID: UInt32 = 0 // getSensorReading(int *, int *)
    private let kGetLEDBrightnessID: UInt32 = 1 // getLEDBrightness(int, int *)
    private let kSetLEDBrightnessID: UInt32 = 2 // setLEDBrightness(int, int, int *)
    private let kSetLEDFadeID: UInt32 = 3 // setLEDFade(int, int, int, int *)
    
    /**
    Initialize the connection to the LMU controller.
    
    :returns: Nil if it failed.
    */
    public init?() {
        let serviceObject = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("AppleLMUController").takeUnretainedValue())
        
        if serviceObject == 0 {
            println("Failed to find ambient light sensor")
            return nil
        }
        
        let kr = IOServiceOpen(serviceObject, mach_task_self_, 0, &dataPort)
        IOObjectRelease(serviceObject)
        
        if kr != KERN_SUCCESS {
            println("Failed to open IOService object")
            return nil
        }
    }
    
    // TODO
    public var displayBrightness: Float? {
        get {
            //            let service = IOServicePortFromCGDisplayID(CGMainDisplayID())
            //            var brightness = HUGE
            //            CGDisplayErr      dErr;
            //            io_service_t      service;
            //            CGDirectDisplayID targetDisplay;
            //
            //            CFStringRef key = CFSTR(kIODisplayBrightnessKey);
            //            float brightness = HUGE_VALF;
            //
            //            targetDisplay = CGMainDisplayID();
            //            service = CGDisplayIOServicePort(targetDisplay);
            //
            //            dErr = IODisplayGetFloatParameter(service, kNilOptions, key, &brightness);
            //
            //            return brightness;
            return nil
        }
    }
    
    /**
    Get MacBook keyboard backlight brightness.
    
    :returns: A value between 0 and 1. Nil if it failed.
    */
    public var keyboardBrightness: Float? {
        get {
            let inputs = [UInt64(0)]
            let outputs = callScalarMethod(kGetLEDBrightnessID, inputs: inputs)
            
            if let a = outputs?.first{
                return Float(a / 0xfff)
            }
            
            return nil
        }
    }
    
    // TODO
    public var lightSensors: LightSensors? {
        get {
            let outputs = callScalarMethod(kGetSensorReadingID, inputs: [UInt64]())
            println(outputs)
            return LightSensors(left: 0, right: 0)
        }
    }
    
    // TODO
    public func setDisplayBrightness(brightness: Float) -> Float? {
        return nil
    }
    
    // TODO
    public func setDisplayWake(wake: Bool) -> Bool? {
        return nil
    }
    
    /**
    Set MacBook keyboard backlight brightness.

    :param: brightness A value between 0 and 1.
    
    :returns: The new brightness value that has been set. Nil if it failed.
    */
    public func setKeyboardBrightness(brightness: Float) -> Float? {
        let inputs = [UInt64(0), UInt64(brightness * 0xfff)]
        let outputs = callScalarMethod(kSetLEDBrightnessID, inputs: inputs)
        
        if let a = outputs?.first{
            return Float(a / 0xfff)
        }
        
        return nil
    }
    
    private func callScalarMethod(selector: UInt32, inputs: [UInt64]) -> [UInt64]? {
        let inputCount = UInt32(inputs.count)
        let inputValues = UnsafeMutablePointer<UInt64>(inputs)
        
        var outputCount = UInt32(1)
        var outputValues = UnsafeMutablePointer<UInt64>(malloc(1*sizeof(UInt64)))
        
        let kr = IOConnectCallScalarMethod(dataPort, selector, inputValues, inputCount, outputValues, &outputCount)
        
        var outputs = [UInt64]()
        for i in 0..<outputCount {
            outputs.append(outputValues[Int(i)])
        }
        
        return kr == KERN_SUCCESS ? outputs : nil
    }
}

public struct LightSensors {
    let left, right: Float
}
