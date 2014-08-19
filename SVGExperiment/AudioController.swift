import AVFoundation
import CoreMedia

@objc protocol AudioControllerDelegate: class {
    optional func audioController(controller: AudioController, didReachBookmark bookmark: AudioTime)
}

private extension CMTime {
    static func fromInterval(interval: NSTimeInterval) -> CMTime {
        return CMTimeMakeWithSeconds(interval, 1000000)
    }

    func toInterval() -> NSTimeInterval {
        return NSTimeInterval(self.value) / NSTimeInterval(self.timescale)
    }
}

class AudioController: AudioBase {
    private var _player: AVPlayer? = nil
    private var _item: AVPlayerItem? = nil
    private var _timeObserver: AnyObject! = nil
    private var _statusObserver: BlockObserver! = nil

    private let _asset: AVAsset
    private var _nextBookmarkIndex: Array<AudioTime>.Index = 0

    let audio: String

    weak var delegate: AudioControllerDelegate? = nil
    var bookmarks: [AudioTime] = []


    init(audio: String) {
        self.audio = audio

        let path = NSBundle.mainBundle().pathForResource(audio, ofType: "")
        _asset = AVURLAsset(URL: NSURL.fileURLWithPath(path), options: [:])
    }
    

    func play(range: AudioInterval) {
        stop()
        
        let item = AVPlayerItem(asset: _asset)
        item.seekToTime(CMTime.fromInterval(range.start))
        item.forwardPlaybackEndTime = CMTime.fromInterval(range.end)
        playItem(item)
    }
    
    func playFromBeginning() {
        stop()
        playItem(AVPlayerItem(asset: _asset))
    }

    func stop() {
        _player?.pause()
        _player?.removeTimeObserver(_timeObserver)
        _player = nil
        
        _item = nil
        _item?.removeObserver(_statusObserver, forKeyPath: "status")
        _nextBookmarkIndex = 0
    }


    private func playItem(item: AVPlayerItem) {
        _player = AVPlayer(playerItem: _item)
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

        _item!.removeObserver(_statusObserver, forKeyPath: "status")
        _statusObserver = nil
    }

    // TODO: We might be able to replace this with a doubly linked list or something where the next
    //   previous item can be easily linked to so that we can support fast seeking operation in the
    //   future.
    private func playerDidObserveTime(time: CMTime) {
        let interval = time.toInterval()
        if _nextBookmarkIndex >= bookmarks.count { return }

        let bookmark = bookmarks[_nextBookmarkIndex]
        if interval > bookmark {
            delegate?.audioController?(self, didReachBookmark: bookmark)
            _nextBookmarkIndex += 1
        }
    }
}
