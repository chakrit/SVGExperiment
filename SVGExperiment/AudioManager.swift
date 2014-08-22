import Foundation

class AudioManager: AudioBase, PlayheadController {
    private var _controllers: [String: AudioController] = Dictionary(minimumCapacity: 5)
    private var _checkpoints: [Playhead] = []
    private var _playhead: Playhead = Playhead()
    
    private(set) var selectedAudio: String? = nil
    
    var onPlayheadChanged: OnPlayheadChangeHandler?
    var playhead: Playhead {
        get { return _playhead }
        set { play(newValue) }
    }
    
    var checkpoints: [Playhead] {
        get { return _checkpoints }
        set {
            var sorted = Array(newValue)
            sorted.sort { $0 < $1 }
            
            stop()
            _checkpoints = newValue
        }
    }
    
    var canPlay: Bool { return true }
    var canPause: Bool { return true }
    
    var selectedAudioController: AudioController? {
        return selectedAudio == nil ? nil : _controllers[selectedAudio!]
    }
    
    subscript(audio: String) -> AudioController {
        if let controller = _controllers[audio] {
            return controller
        }
            
        let controller = AudioController(audio: audio)
        controller.onCurrentTimeUpdated = controllerDidUpdateCurrentTime
            
        let cxx = _controllers[audio]
        _controllers[audio] = controller
        return controller
    }
    
    
    func play() { play(_playhead) }
        
    func play(playhead: Playhead) {
        stop()
        
        let controller = self[playhead.audio]
        controller.onCurrentTimeUpdated = controllerDidUpdateCurrentTime
        
        if playhead.stopTime == 0 {
            controller.play(playhead.time)
        } else {
            controller.play(playhead.time...playhead.stopTime)
        }
        
        selectedAudio = playhead.audio
        
        _playhead = playhead
        onPlayheadChanged?()
    }
        
    func pause() { stop() }
    
    func stop() {
        if let controller = selectedAudioController {
            controller.stop()
            controller.onCurrentTimeUpdated = nil
        }
    }
    
    
    // MARK: KVO
    func controllerDidUpdateCurrentTime() {
        if let controller = selectedAudioController {
            _playhead = Playhead(audio: controller.audio,
                time: controller.currentTime,
                stopTime: _playhead.stopTime)
            onPlayheadChanged?()
        }
    }
}
