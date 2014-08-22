import UIKit

class SliderController: UIViewController, PlayheadController {
    private var _playhead: Playhead = Playhead()
    private var _updating = false
    
    var slider: UISlider { return view as UISlider }
    
    var onPlayheadChanged: OnPlayheadChangeHandler? = nil
    var playhead: Playhead {
        get { return _playhead }
        set {
            _updating = true
            slider.value = Float(_playhead.time)
            _updating = false
            
            _playhead = newValue
            onPlayheadChanged?()
        }
    }
    
    var canPlay: Bool { return false }
    var canPause: Bool { return false }
    
    
    deinit {
        slider.removeObserver(self, forKeyPath: "value")
    }
    
    override func loadView() {
        let s = UISlider(frame: CGRectMake(0, 0, 400, 44))
        s.maximumValue = 100
        s.minimumValue = 0
        
        s.addConstraint(NSLayoutConstraint(item: s, width: 400.0))
        s.addConstraint(NSLayoutConstraint(item: s, height: 44))
        view = s
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        slider.continuous = false
        slider.addTarget(self, action: "sliderValueDidChange", forControlEvents: .ValueChanged)
    }
    
    
    func play() { fatalError("play() not supported.") }
    func pause() { fatalError("pause() not supported.") }
    
    
    func sliderValueDidChange() {
        if _updating { return }
        
        dump("value: \(slider.value)")
        playhead = Playhead(audio: _playhead.audio,
            time: AudioTime(slider.value),
            stopTime: 0)
    }
}
