import Foundation

// TODO: A circular protocol reference causes the Swift compiler to crash, so we're going to use the
//   simpler function assignment (aka target-action pattern), for now.
typealias OnPlayheadChangeHandler = () -> ()

@objc protocol PlayheadController {
    var onPlayheadChanged: OnPlayheadChangeHandler? { get set }
    var playhead: Playhead { get set }
    
    // TODO:
    // var onPlayStateChanged: OnPlayStateChangeHandler? { get set }
    // var isPlaying: Bool { get }
    
    var canPlay: Bool { get }
    var canPause: Bool { get }
    
    func play()
    func pause()
}
