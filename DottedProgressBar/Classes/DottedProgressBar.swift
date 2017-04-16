//
//  DottedProgressBar.swift
//  Pods
//
//  Created by Nikola Corlija on 4/16/17.
//
//

import Foundation
import UIKit

open class DottedProgressBar: UIView {
    
    public struct DottedProgressAppearance {
        let dotRadius: CGFloat
        let dotsColor: UIColor
        let dotsProgressColor: UIColor
        let backColor: UIColor
        
        public init(dotRadius: CGFloat = 8.0, dotsColor: UIColor = UIColor.orange.withAlphaComponent(0.4), dotsProgressColor: UIColor = UIColor.red, backColor: UIColor = UIColor.clear) {
            self.dotRadius = dotRadius
            self.dotsColor = dotsColor
            self.dotsProgressColor = dotsProgressColor
            self.backColor = backColor
        }
    }
    
    var appearance: DottedProgressAppearance!
    
    /// The duration of dots number change animation in seconds.
    open var dotsNumberChangeAnimationDuration: Double = 0.7
    /// The duration of dots progress change animation in seconds.
    open var progressChangeAnimationDuration: Double = 0.8
    /// The time between performing animations from animation queue in seconds.
    open var pauseBetweenConsecutiveAnimations: Double = 1.0
    /// Zoom increase of walking dot while animating progress.
    open var zoomIncreaseValueOnProgressAnimation: CGFloat = 1.5
    
    fileprivate var numberOfDots: Int = 1
    fileprivate var previousProgress: Int = 0
    fileprivate var currentProgress: Int = 0
    
    fileprivate lazy var animationQueue = DottedBarAnimationQueue()
    fileprivate var isAnimatingCurrently: Bool = false
    fileprivate lazy var walkingDot = UIView()
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public init(frame: CGRect) {
        appearance = DottedProgressAppearance()
        super.init(frame: frame)
        setup()
    }
    
    public init(frame: CGRect, numberOfDots: Int, initialProgress: Int) {
        appearance = DottedProgressAppearance()
        super.init(frame: frame)
        self.numberOfDots = numberOfDots
        self.currentProgress = initialProgress
        setup()
    }
    
    public init(appearance: DottedProgressAppearance) {
        self.appearance = appearance
        super.init(frame: CGRect.zero)
        setup()
    }
    
    /**
     Sets a number of steps of progress bar with or without animation.
     
     - parameter count:    Number of steps/dots.
     - parameter animated: Flag for animate effect.
     */
    open func setNumberOfDots(_ count: Int, animated: Bool = true) {
        animationQueue.enqueue(DottedBarAnimation(type: .numberChange, value: count, animated: animated))
        if !isAnimatingCurrently {
            performQueuedAnimations()
        }
    }
    
    /**
     Sets a number of filled dots as current progress with or without animation.
     
     - parameter count:    Number of steps/dots of current progress.
     - parameter animated: Flag for animate effect.
     */
    open func setProgress(_ progress: Int, animated: Bool = true) {
        animationQueue.enqueue(DottedBarAnimation(type: .progresChange, value: progress, animated: animated))
        if !isAnimatingCurrently {
            performQueuedAnimations()
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
}

// MARK: - Private functions

private extension DottedProgressBar {
    
    func setup() {
        backgroundColor = appearance.backColor
        
        for i in 0..<numberOfDots {
            let dot = UIView()
            dot.backgroundColor = i < currentProgress ? appearance.dotsProgressColor : appearance.dotsColor
            dot.layer.cornerRadius = appearance.dotRadius
            dot.frame = dotFrame(forIndex: i)
            addSubview(dot)
        }
    }
    
    func layout() {
        for (index, dot) in subviews.enumerated() {
            if (dot != walkingDot) {
                dot.layer.cornerRadius = appearance.dotRadius
                dot.frame = dotFrame(forIndex: index)
            }
        }
    }
    
    /**
     Calculating frame for given index of dot, supports vertical and horizontal alignment.
     
     - parameter index: Index of dot (including 0).
     */
    func dotFrame(forIndex index: Int) -> CGRect {
        guard index >= 0 else {
            return dotFrame(forIndex: 0)
        }
        if(frame.size.width > frame.size.height) {
            let externalFrameWidth: CGFloat = frame.size.width / CGFloat(numberOfDots)
            let externalFrame = CGRect(x: CGFloat(index) * externalFrameWidth, y: 0, width: externalFrameWidth, height: frame.size.height)
            return CGRect(x: externalFrame.midX - appearance.dotRadius, y: externalFrame.midY - appearance.dotRadius, width: appearance.dotRadius * 2, height: appearance.dotRadius * 2)
        } else {
            let externalFrameHeight: CGFloat = frame.size.height / CGFloat(numberOfDots)
            let externalFrame = CGRect(x: 0, y: CGFloat(index) * externalFrameHeight, width: frame.size.width, height: externalFrameHeight)
            return CGRect(x: externalFrame.midX - appearance.dotRadius, y: externalFrame.midY - appearance.dotRadius, width: appearance.dotRadius * 2, height: appearance.dotRadius * 2)
        }
    }
    
    /**
     Starting execution of all queued animations.
     */
    func performQueuedAnimations() {
        if let nextAnimation = animationQueue.dequeue() {
            isAnimatingCurrently = true
            
            if nextAnimation.type == .numberChange {
                if nextAnimation.value > 0 && nextAnimation.value >= currentProgress && nextAnimation.value != numberOfDots {
                    animateNumberChange(animation: nextAnimation)
                }
                else {
                    print("DottedProgressBar - invalid setNumberOfDots \(nextAnimation.value)")
                    self.performQueuedAnimations()
                }
            }
            else {
                if nextAnimation.value > 0 && nextAnimation.value <= numberOfDots && nextAnimation.value != currentProgress {
                    animateProgress(animation: nextAnimation)
                }
                else {
                    print("DottedProgressBar - invalid setProgress \(nextAnimation.value)")
                    self.performQueuedAnimations()
                }
            }
        }
        else {
            isAnimatingCurrently = false
        }
    }
    
    func animateNumberChange(animation: DottedBarAnimation) {
        numberOfDots = animation.value
        
        if numberOfDots > subviews.count {
            UIView.animate(withDuration: animation.animated ? dotsNumberChangeAnimationDuration * 0.6 : 0.0, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                self.layout()
            }, completion: { done in
                for _ in 0 ..< (self.numberOfDots - self.subviews.count) {
                    let view = UIView()
                    view.backgroundColor = self.appearance.dotsColor
                    view.layer.cornerRadius = self.appearance.dotRadius
                    view.alpha = 0
                    self.addSubview(view)
                }
                UIView.animate(withDuration: animation.animated ? self.dotsNumberChangeAnimationDuration * 0.4 : 0.0, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                    for (_, dot) in self.subviews.enumerated() {
                        dot.alpha = 1
                    }
                }, completion: { done in
                    if animation.animated {
                        DottedBarUtility.delay(self.pauseBetweenConsecutiveAnimations, closure: {
                            self.performQueuedAnimations()
                        })
                    }
                    else {
                        self.performQueuedAnimations()
                    }
                })
                
                self.layout()
            })
        }
        else {
            UIView.animate(withDuration: animation.animated ? self.dotsNumberChangeAnimationDuration * 0.4 : 0.0, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                for index in (Int(self.numberOfDots)..<self.subviews.count).reversed() {
                    self.subviews[index].alpha = 0
                }
            }, completion: { done in
                for index in (Int(self.numberOfDots)..<self.subviews.count).reversed() {
                    self.subviews[index].removeFromSuperview()
                }
                UIView.animate(withDuration: animation.animated ? self.dotsNumberChangeAnimationDuration * 0.6 : 0.0, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                    self.layout()
                }, completion: { done in
                    if animation.animated {
                        DottedBarUtility.delay(self.pauseBetweenConsecutiveAnimations, closure: {
                            self.performQueuedAnimations()
                        })
                    }
                    else {
                        self.performQueuedAnimations()
                    }
                })
            })
        }
    }
    
    func animateProgress(animation: DottedBarAnimation) {
        previousProgress = currentProgress
        currentProgress = animation.value
        
        if animation.animated {
            walkingDot.backgroundColor = appearance.dotsProgressColor
            walkingDot.layer.cornerRadius = appearance.dotRadius
            walkingDot.frame = dotFrame(forIndex: previousProgress - 1)
            addSubview(walkingDot)
            walkingDot.layer.zPosition = 1
            
            UIView.animate(withDuration: progressChangeAnimationDuration * 0.7, delay: 0.0, options: .curveLinear, animations: {
                let frame = self.dotFrame(forIndex: self.currentProgress - 1)
                self.walkingDot.frame = CGRect(x: frame.origin.x - self.zoomIncreaseValueOnProgressAnimation, y: frame.origin.y - self.zoomIncreaseValueOnProgressAnimation, width: self.appearance.dotRadius * 2 + self.zoomIncreaseValueOnProgressAnimation * 2, height: self.appearance.dotRadius * 2 + self.zoomIncreaseValueOnProgressAnimation * 2)
                self.walkingDot.layer.cornerRadius = self.appearance.dotRadius + self.zoomIncreaseValueOnProgressAnimation
            }, completion: nil)
        }
        
        let dotsRange: CountableClosedRange = currentProgress > previousProgress ? previousProgress...currentProgress - 1 : currentProgress...previousProgress - 1
        
        for index in dotsRange {
            UIView.animate(withDuration: 0.1, delay: animation.animated ? progressChangeAnimationDuration * 0.7 * ((Double(index) - Double(previousProgress - 1)) / (Double(currentProgress - 1) - Double(previousProgress - 1))) : 0.0, options: .curveLinear, animations: {
                self.subviews[index].backgroundColor = self.currentProgress > self.previousProgress ? self.appearance.dotsProgressColor : self.appearance.dotsColor
            }, completion: nil)
        }
        
        if animation.animated {
            UIView.animate(withDuration: progressChangeAnimationDuration * 0.3, delay: progressChangeAnimationDuration * 0.7, options: UIViewAnimationOptions(), animations: {
                self.walkingDot.frame = self.dotFrame(forIndex: self.currentProgress - 1)
            }, completion: { done in
                self.walkingDot.removeFromSuperview()
                DottedBarUtility.delay(self.pauseBetweenConsecutiveAnimations, closure: {
                    self.performQueuedAnimations()
                })
            })
        }
        else {
            self.performQueuedAnimations()
        }
    }
    
}

