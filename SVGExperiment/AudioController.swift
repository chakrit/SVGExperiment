import AVFoundation
import CoreMedia

@objc protocol AudioControllerDelegate: class {
    func audioController(controller: AudioController, didReachBookmark bookmark: AudioController.TimeType)
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
    private var _playerItem: AVPlayerItem? = nil
    private var _playerTimeObserver: AnyObject! = nil
    private var _itemStatusObserver: BlockObserver! = nil
    
    private let _asset: AVAsset
    private var _bookmarks: [TimeType] = []
    private var _nextBookmarkIndex: Array<TimeType>.Index = 0

    weak var delegate: AudioControllerDelegate?
    var bookmarks: [TimeType] { return _bookmarks }
    let audio: String
    
    init(audio: String) {
        self.audio = audio
        
        let bundle = NSBundle.mainBundle()
        let path = bundle.pathForResource(audio, ofType: "")
        _asset = AVURLAsset(URL: NSURL.fileURLWithPath(path), options: [:])
    }
    
    func addBookmark(time: TimeType) { _bookmarks.append(time) }
    func clearBookmarks() { _bookmarks.removeAll(keepCapacity: true) }
    
    
    func play(range: IntervalType) { play(startAt: range.start, playUntil: range.end) }
    
    func play(startAt startTime: TimeType, playUntil endTime: TimeType) {
        stop()
        
        let item = AVPlayerItem(asset: _asset)
        item.seekToTime(CMTime.fromInterval(startTime))
        item.forwardPlaybackEndTime = CMTime.fromInterval(endTime)
        playItem(item)
    }
    
    func playFromBeginning() {
        stop()
        playItem(AVPlayerItem(asset: _asset))
    }
    

    private func playItem(item: AVPlayerItem) {
        _playerItem = item
        
        _player = AVPlayer(playerItem: _playerItem)
        _player?.rate = 4.0
        
        _playerTimeObserver = _player?.addPeriodicTimeObserverForInterval(CMTime.fromInterval(0.10),
            queue: dispatch_get_main_queue(),
            usingBlock: playerDidObserveTime)

        if _playerItem!.status == .ReadyToPlay {
            _player!.play()

        } else {
            _itemStatusObserver = _playerItem!.observe("status", usingBlock: itemStatusDidChange)
        }
    }
    
    func stop() {
        _player?.pause()
        _player?.removeTimeObserver(_playerTimeObserver)
        _player = nil
        
        _playerItem = nil
        _nextBookmarkIndex = 0
    }
    

    // MARK: KVO
    private func itemStatusDidChange() {
        if let pi = _playerItem? {
            if pi.status == .ReadyToPlay {
                // TODO: Check if we still wants to play (user hasn't tapped anything else in the meanwhile)
                pi.removeObserver(_itemStatusObserver, forKeyPath: "status")
                _player?.play()
            }
        }
    }

    // TODO: We might be able to replace this with a doubly linked list or something where the next
    //   previous item can be easily linked to so that we can support fast seeking operation in the
    //   future.
    private func playerDidObserveTime(time: CMTime) {
        let interval = time.toInterval()
        if _nextBookmarkIndex >= _bookmarks.count { return }

        let bookmark = _bookmarks[_nextBookmarkIndex]
        if interval > bookmark {
            delegate?.audioController(self, didReachBookmark: bookmark)
            _nextBookmarkIndex += 1
        }
    }
}
