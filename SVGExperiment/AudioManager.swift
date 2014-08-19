import Foundation

@objc protocol AudioManagerDelegate: class {
    optional func audioManager(manager: AudioManager, didReachBookmark bookmark: AudioTime, ofAudio audio: String)
    optional func audioManager(manager: AudioManager, didBeginPlayingAudio audio: String)
    optional func audioManager(manager: AudioManager, didStopPlayingAudio audio: String)
}

class AudioManager: AudioBase, AudioControllerDelegate {
    private var _controllers: [String: AudioController] = Dictionary(minimumCapacity: 5)
    private var _bookmarks: [AudioTime] = []
    
    private(set) var selectedAudio: String? = nil
    private(set) var selectedTimeInterval: AudioInterval? = nil
    
    weak var delegate: AudioManagerDelegate? = nil
    var bookmarks: [AudioTime] {
        get { return _bookmarks }
        set {
            var sorted = Array(newValue)
            sorted.sort { $0 < $1 }
            _bookmarks = sorted
        }
    }
    
    var selectedAudioController: AudioController? {
        return selectedAudio == nil ? nil : _controllers[selectedAudio!]
    }
    
    subscript(audio: String) -> AudioController {
        if let controller = _controllers[audio] {
            return controller
        }
            
        let controller = AudioController(audio: audio)
        controller.delegate = self
            
        let cxx = _controllers[audio]
        _controllers[audio] = controller
        return controller
    }
    
    
    func play(audio: String, inRange range: AudioInterval? = nil) {
        if let previousController = selectedAudioController {
            previousController.stop()
            previousController.delegate = nil
        }
        
        let controller = self[audio]
        controller.bookmarks = _bookmarks
        controller.delegate = self

        if let r = range {
            controller.play(r)
        } else {
            controller.playFromBeginning()
        }
        
        selectedAudio = audio
        selectedTimeInterval = range
        delegate?.audioManager?(self, didBeginPlayingAudio: audio)
    }
    
    func stop() {
        if let controller = selectedAudioController {
            controller.stop()
            delegate?.audioManager?(self, didStopPlayingAudio: controller.audio)
        }
    }
    
    
    // MARK: AudioControllerDelegate
    func audioController(controller: AudioController, didReachBookmark bookmark: AudioTime) {
        delegate?.audioManager?(self, didReachBookmark: bookmark, ofAudio: controller.audio)
    }
}
