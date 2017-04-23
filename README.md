![alt tag](https://s24.postimg.org/ok064585x/dotted-progress-title.png)

[comment]: # [![CI Status](http://img.shields.io/travis/nikola9core/DottedProgressBar.svg?style=flat)](https://travis-ci.org/nikola9core/DottedProgressBar)
[![Version](https://img.shields.io/cocoapods/v/DottedProgressBar.svg?style=flat)](http://cocoapods.org/pods/DottedProgressBar)
[![License](https://img.shields.io/cocoapods/l/DottedProgressBar.svg?style=flat)](http://cocoapods.org/pods/DottedProgressBar)
[![Platform](https://img.shields.io/cocoapods/p/DottedProgressBar.svg?style=flat)](http://cocoapods.org/pods/DottedProgressBar)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

![alt tag](https://gifyu.com/images/dotted-progress-bar-ezgif-480.gif)

## Requirements
* iOS 8.0+
* Swift 3.0+

## Installation

DottedProgressBar is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "DottedProgressBar"
```
## Easy to use
Import library
```swift
import DottedProgressBar
```

Initialize `DottedProgressBar` in one line of code
```swift
let progressBar = DottedProgressBar(frame: CGRect(x: 50, y: 50, width: 200, height: 20),
                                    numberOfDots: 6,
                                    initialProgress: 1)
view.addSubview(progressBar)
```

## Custom appearance
```swift
let progressBar = DottedProgressBar()
progressBar.appearance = DottedProgressBar.DottedProgressAppearance(
    dotRadius: 8.0,
    dotsColor: UIColor.orange.withAlphaComponent(0.5),
    dotsProgressColor: UIColor.red,
    backColor: UIColor.clear
)
view.addSubview(progressBar)
progressBar.frame = CGRect(x: 50, y: 50, width: 200, height: 20)

progressBar.setNumberOfDots(6, animated: false)
progressBar.setProgress(1, animated: false)
```

## Animations
Animations can be called repeatedly because they have its own queue. Each animation will wait previous to finish and then will be executed.
```swift
self.setProgress(4, animated: true)
self.setNumberOfDots(8, animated: true)
```

## Customize animations

Customize duration of animations and pause between consecutive animations
```swift
progressBar.dotsNumberChangeAnimationDuration = 0.6
progressBar.progressChangeAnimationDuration = 0.7
progressBar.pauseBetweenConsecutiveAnimations = 1.0
```

## License

DottedProgressBar is available under the MIT license. See the LICENSE file for more info.
