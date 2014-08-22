import Foundation

class Playhead: AudioBase {
    let audio: String
    let time: AudioTime
    let stopTime: AudioTime

    override convenience init() {
        self.init(audio: "", time: 0, stopTime: 0)
    }
    
    init(audio: String, time: AudioTime, stopTime: AudioTime = 0) {
        self.audio = audio
        self.time = time
        self.stopTime = stopTime
    }
}

func ==(p1: Playhead, p2: Playhead) -> Bool { return p1.audio == p2.audio && p1.time == p2.time }
func !=(p1: Playhead, p2: Playhead) -> Bool { return !(p1 == p2) }

func <(p1: Playhead, p2: Playhead) -> Bool {
    return p1.audio < p2.audio || p1.time < p2.time || p1.stopTime < p2.stopTime
}

func >(p1:Playhead, p2: Playhead) -> Bool {
    return p1.audio > p2.audio || p1.time > p2.time || p1.stopTime > p2.stopTime
}
