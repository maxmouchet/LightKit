//
//  LightKit.swift
//  LightKit
//
//  Created by Max Mouchet on 04/05/15.
//
//  Ported from https://github.com/samnung/maclight/
//  See license below.
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
import Foundation
import CoreGraphics

open class LightKit {
    fileprivate var dataPort: io_connect_t = 0

    fileprivate let kGetSensorReadingID: UInt32 = 0 // getSensorReading(int *, int *)
    fileprivate let kGetLEDBrightnessID: UInt32 = 1 // getLEDBrightness(int, int *)
    fileprivate let kSetLEDBrightnessID: UInt32 = 2 // setLEDBrightness(int, int, int *)
    fileprivate let kSetLEDFadeID: UInt32 = 3 // setLEDFade(int, int, int, int *)

    /**
     Initialize LightKit.

     - returns: Nil if it failed.
     */
    public init?() {
        if !initLMUService() { return nil }
    }

    /**
     Get MacBook display backlight brightness.

     - returns: A value between 0 and 1. Nil if it failed.
     */
    open var displayBrightness: Float? {
        get {
            var iterator: io_iterator_t = 0

            let result = IOServiceGetMatchingServices(kIOMasterPortDefault,
                                                      IOServiceMatching("IODisplayConnect"),
                                                      &iterator)

            if result == kIOReturnSuccess {
                var service: io_service_t = 1

                while true {
                    service = IOIteratorNext(iterator)

                    if service == 0 { break; }

                    var brightness: Float = 0
                    IODisplayGetFloatParameter(service, UInt32(0), kIODisplayBrightnessKey as CFString!, &brightness)
                    IOObjectRelease(service)
                    return brightness
                }
            }

            return nil
        }
    }

    /**
     Get MacBook keyboard backlight brightness.

     - returns: A value between 0 and 1. Nil if it failed.
     */
    open var keyboardBrightness: Float? {
        get {
            let inputs = [UInt64(0)]
            let outputs = callScalarMethod(kGetLEDBrightnessID, inputs: inputs, outputCount: 1)

            if let a = outputs?.first{
                return Float(a / 0xfff)
            }

            return nil
        }
    }

    /**
     Get MacBook ambient light sensors values.

     - returns: The readings from the sensors. Nil if it failed.
     */
    open var lightSensors: LightSensors? {
        get {
            let outputs = callScalarMethod(kGetSensorReadingID, inputs: [UInt64](), outputCount: 2)

            if let left = outputs?.first, let right = outputs?.last {
                return LightSensors(left: Float(left / 2000), right: Float(right / 2000))
            }

            return nil
        }
    }

    /**
     Set MacBook display backlight brightness.

     - parameter brightness: A value between 0 and 1.

     - returns: True if it succeeded. False if it failed.
     */
    open func setDisplayBrightness(_ brightness: Float) -> Bool {
        var iterator: io_iterator_t = 0

        let result = IOServiceGetMatchingServices(kIOMasterPortDefault,
                                                  IOServiceMatching("IODisplayConnect"),
                                                  &iterator)

        if result == kIOReturnSuccess {
            var service: io_service_t = 1

            while true {
                service = IOIteratorNext(iterator)

                if service == 0 { break; }

                IODisplaySetFloatParameter(service, UInt32(0), kIODisplayBrightnessKey as CFString!, brightness)
                IOObjectRelease(service)
            }
        } else {
            return false
        }

        return true
    }

    /**
     Set MacBook display power status.

     - parameter on: Whether the display should be on or off.

     - returns: True if it succeeded. False if it failed.
     */
    open func setDisplayPower(_ on: Bool) -> Bool {
        let entry = IORegistryEntryFromPath(kIOMasterPortDefault, "IOService:/IOResources/IODisplayWrangler")

        if entry != 0 {
            IORegistryEntrySetCFProperty(entry, "IORequestIdle" as CFString!, on ? kCFBooleanFalse : kCFBooleanTrue)
            IOObjectRelease(entry)
            return true
        }

        return false
    }

    /**
     Set MacBook keyboard backlight brightness.

     - parameter brightness: A value between 0 and 1.

     - returns: The new brightness value that has been set. Nil if it failed.
     */
    open func setKeyboardBrightness(_ brightness: Float) -> Float? {
        let inputs = [UInt64(0), UInt64(brightness * 0xfff)]
        let outputs = callScalarMethod(kSetLEDBrightnessID, inputs: inputs, outputCount: 1)

        if let a = outputs?.first{
            return Float(a / 0xfff)
        }

        return nil
    }

    /**
     Open a connection to the LMU controller.
     */
    fileprivate func initLMUService() -> Bool {
        let serviceObject = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("AppleLMUController"))

        if serviceObject == 0 {
            print("Failed to find ambient light sensor")
            return false
        }

        let kr = IOServiceOpen(serviceObject, mach_task_self_, 0, &dataPort)
        IOObjectRelease(serviceObject)

        if kr != KERN_SUCCESS {
            print("Failed to open IOService object")
            return false
        }
        
        return true
    }
    
    /**
     Wrapper for IOConnectCallScalarMethod.
     */
    fileprivate func callScalarMethod(_ selector: UInt32, inputs: [UInt64], outputCount: Int) -> [UInt64]? {
        let inputCount = UInt32(inputs.count)
        let inputValues = UnsafeMutablePointer<UInt64>(mutating: inputs)
        
        var outputCount = UInt32(outputCount)
        let outputValues = UnsafeMutablePointer<UInt64>.allocate(capacity: 1)

        let kr = IOConnectCallScalarMethod(dataPort, selector, inputValues, inputCount, outputValues, &outputCount)

        var outputs = [UInt64]()
        for i in 0..<outputCount {
            outputs.append(outputValues[Int(i)])
        }

        return kr == KERN_SUCCESS ? outputs : nil
    }
}

/// Readings from the ambient light sensor
public struct LightSensors {
    public let left, right: Float
}
