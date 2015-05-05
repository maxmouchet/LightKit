# LightKit
Access the ambient light sensors, and control MacBook's display & keyboard brightness in Swift.

**Warning:** While it may seems safe to play with the backlight, I am not responsible for any damages made to a computer using this code.

## Installation

## Usage
```swift
import LightKit
let lk = LightKit()! // May be nil if it failed to open I/Os.
```

#### Ambient light sensors
```swift
let lightSensorsReadings = lk.lightSensors
println("Left sensor: \(lightSensorsReadings.left).")
println("Right sensor: \(lightSensorsReadings.right).")
```

#### Display
```swift
println("Display brightness is \(lk.displayBrightness)")
lk.setDisplayBrightness(0.8) // A value between 0 and 1.
```

```swift
lk.setDisplayPower(false) // Put display to sleep
lk.setDisplayPower(true) // Wake up display
```

#### Keyboard
```swift
println("Keyboard brightness is \(lk.keyboardBrightness)")
lk.setKeyboardBrightness(0.8) // A value between 0 and 1.
```
