# LightKit
Access the ambient light sensor, and control MacBook's display & keyboard brightness in Swift.

**Warning:** While it may seems safe to play with the backlight, I am not responsible for any damages made to a computer using this code.

## Installation

## Usage

```swift
import LightKit

let lmu = LMUController()

lmu?.setKeyboardBrightness(0.8) // A value between 0 and 1.
```
