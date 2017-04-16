//
//  DottedBarAnimationQueue.swift
//  Pods
//
//  Created by Nikola Corlija on 4/16/17.
//
//

import Foundation

struct DottedBarAnimationQueue {
    
    //can be optimized as linked list
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

enum DottedBarAnimationType {
    case numberChange
    case progresChange
}

class DottedBarUtility {
    /**
     Utility static function for delaying job on main thread.
     
     - parameter delay:   The time interval for delaying in seconds.
     - parameter closure: The code to be executed after delay time passes.
     */
    static func delay(_ delay: Double, closure: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + delay, execute: closure
        )
    }
}
