// https://github.com/Quick/Quick

import Quick
import Nimble
import DottedProgressBar

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        describe("progress bar view") {
            
            it("count dots") {
                let progressBar = DottedProgressBar()
                progressBar.setNumberOfDots(6, animated: false)
                expect(progressBar.subviews.count) == 6
            }
            
        }
    }
}
