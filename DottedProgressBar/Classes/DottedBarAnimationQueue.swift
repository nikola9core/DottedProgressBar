//
//  DottedBarAnimationQueue.swift
//  Pods
//
//  Created by Nikola Corlija on 4/16/17.
//
//

import Foundation

struct DottedBarAnimationQueue {
    
    var queue = [DottedBarAnimation]()
    
    var isEmpty: Bool {
        return queue.isEmpty
    }
    
    mutating func enqueue(_ element: DottedBarAnimation) {
        queue.append(element)
    }
    
    mutating func dequeue() -> DottedBarAnimation? {
        if !queue.isEmpty {
            return queue.removeFirst()
        } else {
            return nil
        }
    }
    
    func peek() -> DottedBarAnimation? {
        if !queue.isEmpty {
            return queue[0]
        } else {
            return nil
        }
    }
    
}

struct DottedBarAnimation {
    var type: DottedBarAnimationType = .numberChange
    var value: Int = 0
    var animated: Bool = false
}

/// Animation type while setting number of dots or current progress
///
/// - numberChange: Change of number of progress steps
/// - progresChange: Change of progress
enum DottedBarAnimationType {
    case numberChange
    case progresChange
}

public class DottedBarUtility {
    /// Utility static function for delaying job on main thread.
    ///
    /// - Parameters:
    ///   - delay: The time interval for delaying in seconds.
    ///   - closure: The code to be executed after delay time passes.
    public static func delay(_ delay: Double, closure: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + delay, execute: closure
        )
    }
}
