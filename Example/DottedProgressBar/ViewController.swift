//
//  ViewController.swift
//  DottedProgressBar
//
//  Created by nikola9core on 04/16/2017.
//  Copyright (c) 2017 nikola9core. All rights reserved.
//

import UIKit
import DottedProgressBar

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let progressBar = DottedProgressBar()
        
        //appearance
        progressBar.progressAppearance = DottedProgressBar.DottedProgressAppearance(
            dotRadius: 8.0,
            dotsColor: UIColor.orange.withAlphaComponent(0.4),
            dotsProgressColor: UIColor.red,
            backColor: UIColor.clear
        )
        
        progressBar.frame = CGRect(x: 50, y: 50, width: 200, height: 20)
        view.addSubview(progressBar)
        
        //set number of steps and current progress
        progressBar.setNumberOfDots(6, animated: false)
        progressBar.setProgress(1, animated: false)
        
        //customize animation
        progressBar.dotsNumberChangeAnimationDuration = 0.6
        progressBar.progressChangeAnimationDuration = 0.7
        progressBar.pauseBetweenConsecutiveAnimations = 1.0
        
        //perform animations
        progressBar.setProgress(4)
        progressBar.setNumberOfDots(7)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

