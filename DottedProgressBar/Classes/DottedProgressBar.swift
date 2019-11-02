//
//  DottedProgressBar.swift
//  Pods
//
//  Created by Nikola Corlija on 4/16/17.
//
//

import Foundation
import UIKit

// swiftlint:disable function_body_length

open class DottedProgressBar: UIView {
    
    public struct DottedProgressAppearance {
        let dotRadius: CGFloat
        let dotsColor: UIColor
        let dotsProgressColor: UIColor
        let backColor: UIColor
        let borderColor:UIColor
        let borderWidth:CGFloat
        
        public init(dotRadius: CGFloat = 8.0,
                    dotsColor: UIColor = UIColor.orange.withAlphaComponent(0.4),
                    dotsProgressColor: UIColor = UIColor.red,
                    backColor: UIColor = UIColor.clear,
                    borderColor:UIColor = UIColor.clear,
                    borderWidth:CGFloat = 0.0) {
            self.dotRadius = dotRadius
            self.dotsColor = dotsColor
            self.dotsProgressColor = dotsProgressColor
            self.backColor = backColor
            self.borderWidth = borderWidth
            self.borderColor = borderColor
        }
    }
    
    open var progressAppearance: DottedProgressAppearance!
    
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
        
        progressAppearance = DottedProgressAppearance()
        super.init(frame: frame)
    }
    
    override public init(frame: CGRect) {
        progressAppearance = DottedProgressAppearance()
        super.init(frame: frame)
        setup()
    }
    
    public init(frame: CGRect, numberOfDots: Int, initialProgress: Int) {
        progressAppearance = DottedProgressAppearance()
        super.init(frame: frame)
        self.numberOfDots = numberOfDots
        self.currentProgress = initialProgress
        setup()
    }
    
    public init(appearance: DottedProgressAppearance) {
        self.progressAppearance = appearance
        super.init(frame: CGRect.zero)
        setup()
    }
    
    open func offAnimation() {
        dotsNumberChangeAnimationDuration = 0
        progressChangeAnimationDuration = 0
        pauseBetweenConsecutiveAnimations = 0
    }
    /// Sets a number of steps of progress bar with or without animation.
    ///
    /// - Parameters:
    ///   - count: Number of steps/dots.
    ///   - animated: Flag for animate effect.
    open func setNumberOfDots(_ count: Int, animated: Bool = true) {
        animationQueue.enqueue(DottedBarAnimation(type: .numberChange, value: count, animated: animated))
        if !isAnimatingCurrently {
            performQueuedAnimations()
        }
    }
    
    /// Sets a number of filled dots as current progress with or without animation.
    ///
    /// - Parameters:
    ///   - progress: Number of steps/dots of current progress.
    ///   - animated: Flag for animate effect.
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
        backgroundColor = progressAppearance.backColor
        
        for i in 0..<numberOfDots {
            let dot = UIView()
            dot.backgroundColor = i < currentProgress ? progressAppearance.dotsProgressColor :
                progressAppearance.dotsColor
            dot.layer.cornerRadius = progressAppearance.dotRadius
            dot.layer.borderColor = progressAppearance.borderColor.cgColor
            dot.layer.borderWidth = progressAppearance.borderWidth
            dot.frame = dotFrame(forIndex: i)
            addSubview(dot)
        }
    }
    
    func layout() {
        for (index, dot) in subviews.enumerated() where dot != walkingDot {
            dot.layer.cornerRadius = progressAppearance.dotRadius
            dot.layer.borderColor = progressAppearance.borderColor.cgColor
            dot.layer.borderWidth = progressAppearance.borderWidth
            dot.frame = dotFrame(forIndex: index)
        }
    }
    
    /// Calculating frame for given index of dot, supports vertical and horizontal alignment.
    ///
    /// - Parameter index: Index of dot (including 0).
    /// - Returns: Frame rectangle for given dot index
    func dotFrame(forIndex index: Int) -> CGRect {
        guard index >= 0 else {
            return dotFrame(forIndex: 0)
        }
        if frame.size.width > frame.size.height {
            let externalFrameWidth: CGFloat = frame.size.width / CGFloat(numberOfDots)
            let externalFrame = CGRect(x: CGFloat(index) * externalFrameWidth,
                                       y: 0, width: externalFrameWidth,
                                       height: frame.size.height)
            return CGRect(x: externalFrame.midX - progressAppearance.dotRadius,
                          y: externalFrame.midY - progressAppearance.dotRadius,
                          width: progressAppearance.dotRadius * 2,
                          height: progressAppearance.dotRadius * 2)
        } else {
            let externalFrameHeight: CGFloat = frame.size.height / CGFloat(numberOfDots)
            let externalFrame = CGRect(x: 0,
                                       y: CGFloat(index) * externalFrameHeight,
                                       width: frame.size.width,
                                       height: externalFrameHeight)
            return CGRect(x: externalFrame.midX - progressAppearance.dotRadius,
                          y: externalFrame.midY - progressAppearance.dotRadius,
                          width: progressAppearance.dotRadius * 2,
                          height: progressAppearance.dotRadius * 2)
        }
    }
    
    /// Starting execution of all queued animations.
    func performQueuedAnimations() {
        if let nextAnimation = animationQueue.dequeue() {
            isAnimatingCurrently = true
            if nextAnimation.type == .numberChange {
                if nextAnimation.value > 0 &&
                    nextAnimation.value >= currentProgress &&
                    nextAnimation.value != numberOfDots {
                    animateNumberChange(animation: nextAnimation)
                } else {
                    print("DottedProgressBar - invalid setNumberOfDots \(nextAnimation.value)")
                    self.performQueuedAnimations()
                }
            } else {
                if nextAnimation.value > 0 &&
                    nextAnimation.value <= numberOfDots &&
                    nextAnimation.value != currentProgress {
                    animateProgress(animation: nextAnimation)
                } else {
                    print("DottedProgressBar - invalid setProgress \(nextAnimation.value)")
                    self.performQueuedAnimations()
                }
            }
        } else {
            isAnimatingCurrently = false
        }
    }
    
    /// Performs animation for changing the number of dots
    ///
    /// - Parameter animation: The animation model
    func animateNumberChange(animation: DottedBarAnimation) {
        numberOfDots = animation.value
        
        if numberOfDots > subviews.count {
            UIView.animate(withDuration: animation.animated ? dotsNumberChangeAnimationDuration * 0.6 : 0.0,
                           delay: 0.0, options: UIView.AnimationOptions(), animations: {
                            self.layout()
            }, completion: { _ in
                for _ in 0 ..< (self.numberOfDots - self.subviews.count) {
                    let view = UIView()
                    view.backgroundColor = self.progressAppearance.dotsColor
                    view.layer.cornerRadius = self.progressAppearance.dotRadius
                    view.layer.borderColor = self.progressAppearance.borderColor.cgColor
                    view.layer.borderWidth = self.progressAppearance.borderWidth
                    view.alpha = 0
                    self.addSubview(view)
                }
                UIView.animate(withDuration: animation.animated ? self.dotsNumberChangeAnimationDuration * 0.4 : 0.0,
                               delay: 0.0,
                               options: UIView.AnimationOptions(), animations: {
                                for dot in self.subviews {
                                    dot.alpha = 1
                                }
                }, completion: { _ in
                    if animation.animated {
                        DottedBarUtility.delay(self.pauseBetweenConsecutiveAnimations, closure: {
                            self.performQueuedAnimations()
                        })
                    } else {
                        self.performQueuedAnimations()
                    }
                })
                
                self.layout()
            })
        } else {
            UIView.animate(withDuration: animation.animated ? self.dotsNumberChangeAnimationDuration * 0.4 : 0.0,
                           delay: 0.0,
                           options: UIView.AnimationOptions(),
                           animations: {
                            for index in (Int(self.numberOfDots)..<self.subviews.count).reversed() {
                                self.subviews[index].alpha = 0
                            }
            }, completion: { _ in
                for index in (Int(self.numberOfDots)..<self.subviews.count).reversed() {
                    self.subviews[index].removeFromSuperview()
                }
                UIView.animate(withDuration: animation.animated ? self.dotsNumberChangeAnimationDuration * 0.6 : 0.0,
                               delay: 0.0,
                               options: UIView.AnimationOptions(),
                               animations: {
                                self.layout()
                }, completion: { _ in
                    if animation.animated {
                        DottedBarUtility.delay(self.pauseBetweenConsecutiveAnimations, closure: {
                            self.performQueuedAnimations()
                        })
                    } else {
                        self.performQueuedAnimations()
                    }
                })
            })
        }
    }
    
    /// Performs animation for changing the current progress
    ///
    /// - Parameter animation: The animation model
    func animateProgress(animation: DottedBarAnimation) {
        previousProgress = currentProgress
        currentProgress = animation.value
        
        if animation.animated {
            walkingDot.backgroundColor = progressAppearance.dotsProgressColor
            walkingDot.layer.cornerRadius = progressAppearance.dotRadius
            walkingDot.layer.borderColor = progressAppearance.borderColor.cgColor
            walkingDot.layer.borderWidth = progressAppearance.borderWidth
            walkingDot.frame = dotFrame(forIndex: previousProgress - 1)
            addSubview(walkingDot)
            walkingDot.layer.zPosition = 1
            
            UIView.animate(withDuration: progressChangeAnimationDuration * 0.7,
                           delay: 0.0,
                           options: .curveLinear,
                           animations: {
                            let frame = self.dotFrame(forIndex: self.currentProgress - 1)
                            self.walkingDot.frame = CGRect(x: frame.origin.x - self.zoomIncreaseValueOnProgressAnimation,
                                                           y: frame.origin.y - self.zoomIncreaseValueOnProgressAnimation,
                                                           width:
                                self.progressAppearance.dotRadius * 2 +
                                    self.zoomIncreaseValueOnProgressAnimation * 2,
                                                           height:
                                self.progressAppearance.dotRadius * 2 +
                                    self.zoomIncreaseValueOnProgressAnimation * 2)
                            self.walkingDot.layer.cornerRadius =
                                self.progressAppearance.dotRadius +
                                self.zoomIncreaseValueOnProgressAnimation
            }, completion: nil)
        }
        
        let dotsRange: CountableClosedRange = currentProgress > previousProgress ?
            previousProgress...currentProgress - 1 :
            currentProgress...previousProgress - 1
        
        for index in dotsRange {
            UIView.animate(withDuration: 0.1,
                           delay:
                animation.animated ?
                    progressChangeAnimationDuration * 0.7 *
                        ((Double(index) - Double(previousProgress - 1)) / (Double(currentProgress - 1) -
                            Double(previousProgress - 1))) : 0.0,
                           options: .curveLinear,
                           animations: {
                            self.subviews[index].backgroundColor =
                                self.currentProgress > self.previousProgress ?
                                    self.progressAppearance.dotsProgressColor :
                                self.progressAppearance.dotsColor
            }, completion: nil)
        }
        
        if animation.animated {
            UIView.animate(withDuration: progressChangeAnimationDuration * 0.3,
                           delay: progressChangeAnimationDuration * 0.7,
                           options: UIView.AnimationOptions(),
                           animations: {
                            self.walkingDot.frame = self.dotFrame(forIndex: self.currentProgress - 1)
            }, completion: { _ in
                self.walkingDot.removeFromSuperview()
                DottedBarUtility.delay(self.pauseBetweenConsecutiveAnimations, closure: {
                    self.performQueuedAnimations()
                })
            })
        } else {
            self.performQueuedAnimations()
        }
    }
}
