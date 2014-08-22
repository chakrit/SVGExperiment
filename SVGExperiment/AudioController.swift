import AVFoundation
import CoreMedia

private extension CMTime {
    static func fromInterval(interval: NSTimeInterval) -> CMTime {
        return CMTimeMakeWithSeconds(interval, 1000000)
    }

    func toInterval() -> NSTimeInterval {
        return NSTimeInterval(self.value) / NSTimeInterval(self.timescale)
    }
}

typealias OnCurrentTimeUpdateHandler = () -> ()

class AudioController: AudioBase {
    private var _player: AVPlayer? = nil
    private var _item: AVPlayerItem? = nil
    private let _asset: AVAsset

    private var _timeObserver: AnyObject? = nil
    private var _statusObserver: BlockObserver? = nil

    var onCurrentTimeUpdated: OnCurrentTimeUpdateHandler? = nil
    private(set) var currentTime: AudioTime = 0

    let audio: String

    init(audio: String) {
        self.audio = audio

        if let path = NSBundle.mainBundle().pathForResource(audio, ofType: "") {
            _asset = AVURLAsset(URL: NSURL.fileURLWithPath(path), options: [:])
        } else {
            dump(audio, name: "audio")
            fatalError("failed to load audio.")
        }
    }
    

    func play(range: AudioInterval) {
        stop()
        
        let item = AVPlayerItem(asset: _asset)
        item.seekToTime(CMTime.fromInterval(range.start))
        item.forwardPlaybackEndTime = CMTime.fromInterval(range.end)
        playItem(item)
    }
    
    func play(time: AudioTime) {
        stop()

        let item = AVPlayerItem(asset: _asset)
        item.seekToTime(CMTime.fromInterval(time))
        playItem(item)
    }

    func playFromBeginning() {
        stop()
        playItem(AVPlayerItem(asset: _asset))
    }

    func stop() {
        _player?.pause()
        _player?.removeTimeObserver(_timeObserver?)
        _player = nil
        
        if let so = _statusObserver {
            _item?.removeObserver(so, forKeyPath: "status")
        }

        _item = nil
    }


    private func playItem(item: AVPlayerItem) {
        // TODO: Make time observer resolution configurable so we can fine-tune perf later.
        _player = AVPlayer(playerItem: item)
        _timeObserver = _player?.addPeriodicTimeObserverForInterval(CMTime.fromInterval(0.10),
            queue: dispatch_get_main_queue(),
            usingBlock: playerDidObserveTime)

        _item = item
        if _item!.status == .ReadyToPlay {
            _player!.play()

        } else {
            _statusObserver = _item!.observe("status", usingBlock: itemStatusDidChange)
        }
    }
    

    // MARK: KVO
    private func itemStatusDidChange() {
        if _item == nil { return }

        // TODO: Delegate methods for audio load/fail status? We don't need this for now but we
        //   might want to have warnings when the content is malformed so it's easier to debug the
        //   book content.
        switch _item!.status {
        case .ReadyToPlay: _player?.play()
        case .Failed: dump(_item!, name: "failed to play item.")

        case .Unknown:
            dump(_item!, name: "item has unknown status.")
            return
        }

        _item!.removeObserver(_statusObserver?, forKeyPath: "status")
        _statusObserver = nil
    }

    private func playerDidObserveTime(time: CMTime) {
        currentTime = time.toInterval()
        onCurrentTimeUpdated?()
    }
}
