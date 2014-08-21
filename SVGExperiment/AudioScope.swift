import Foundation

class AudioScope: AudioBase {
    let audio: String
    let interval: AudioInterval
    
    init(audio: String, interval: AudioInterval) {
        self.audio = audio
        self.interval = interval
    }
}
