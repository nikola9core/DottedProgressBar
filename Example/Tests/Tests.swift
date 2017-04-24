// https://github.com/Quick/Quick

import Quick
import Nimble
import DottedProgressBar
import UIKit

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        describe("dotted progress bar view") {
            
            it("count dots after async animation") {
                let progressBar = DottedProgressBar()
                progressBar.setNumberOfDots(6, animated: true)
                
                //toEventually will check condition after animation completed
                expect(progressBar.subviews.count).toEventually(equal(6))
            }
            
            it("checks dots color after async animation") {
                waitUntil { done in
                    let progressBar = DottedProgressBar()
                    progressBar.progressAppearance = DottedProgressBar.DottedProgressAppearance(
                        dotRadius: 8.0,
                        dotsColor: UIColor.orange,
                        dotsProgressColor: UIColor.red,
                        backColor: UIColor.clear
                    )
                    
                    progressBar.setNumberOfDots(8, animated: false)
                    progressBar.setProgress(3, animated: true)
                    
                    DottedBarUtility.delay(progressBar.progressChangeAnimationDuration + 0.1) {
                        expect(progressBar.subviews[2].backgroundColor).to(equal(UIColor.red))
                        expect(progressBar.subviews[3].backgroundColor).to(equal(UIColor.orange))
                        done()
                    }
                }
            }
            
        }
    }
}
