import UIKit

@objc class PlayheadSynchronizer: NSObject {
    var _propagating: Bool = false
    let controllers: [PlayheadController] = []
    
    init(controllers: PlayheadController...) {
        self.controllers = controllers
        super.init()
        
        for c in controllers {
            c.onPlayheadChanged = propagatePlayhead(from: c)
        }
    }
    
    
    private func propagatePlayhead(from src: PlayheadController) () -> () {
        for c in controllers {
            if c.playhead != src.playhead {
                c.playhead = src.playhead
                if c.canPlay { c.play() }
            }
        }
    }
}
