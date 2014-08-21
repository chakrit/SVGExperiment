import UIKit
import QuartzCore

class RootViewController: UIViewController, AudioManagerDelegate {
    typealias ImageView = SVGKLayeredImageView
    
    private let _audioManager = AudioManager()
    
    private var _image: SVGKImage! = nil
    private var _interactiveElements: [Element] = []
    private var _elementIntervals: [Element: AudioInterval] = [:]
    
    
    convenience override init() { self.init(nibName: nil, bundle: nil) }
    required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        _audioManager.delegate = self
    }
    
    
    override func loadView() {
        var screenSize = UIScreen.mainScreen().bounds.size
        if screenSize.height > screenSize.width {
            screenSize = CGSize(width: screenSize.height, height: screenSize.width)
        }

        let frame = CGRect(origin: CGPointZero, size: screenSize)
        let v = UIView(frame: frame)
        v.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        v.backgroundColor = .whiteColor()

        if _image == nil { loadImage() }
        let size = _image.size
        
        let svgFrame = CGRect(origin: CGPointZero, size: size)
        let svg = ImageView(frame: svgFrame)
        svg.setTranslatesAutoresizingMaskIntoConstraints(false)
        svg.backgroundColor = .whiteColor()
        svg.contentMode = .ScaleAspectFit
        svg.image = _image
        v.addSubview(svg)

        v.addConstraint(NSLayoutConstraint(horizontalAlignItem: svg, withItem: v))
        v.addConstraint(NSLayoutConstraint(verticalAlignItem: svg, withItem: v))
        v.addConstraint(NSLayoutConstraint(item: svg, width: size.width))
        v.addConstraint(NSLayoutConstraint(item: svg, height: size.height))
        view = v
    }
    
    func loadImage() {
//        if _image != nil { return }
//        _image = SVGKImage(named: "twinkle.svg")
//        
//        
//        let elements = _image.DOMTree.getElementsByTagName("*")
//        _interactiveElements = []
//        _elementIntervals = [:]
//        _audioManager.bookmarks = []
//        
//        for var i = 0; i < elements.length; i++ {
//            let element = elements.item(Int32(i)) as Element
//            if element.hasAttribute("interval") {
//                let interval = parseInterval(element.getAttribute("interval"))
//                _elementIntervals[element] = interval
//                _interactiveElements += [element]
//                _audioManager.bookmarks += [interval.start]
//            }
//        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _audioManager.play("twinkle.mp3")
    }
    
    
    // MARK: AudioManagerDelegate
    func audioManager(manager: AudioManager, didReachBookmark bookmark: AudioTime, ofAudio audio: String) {
        dump((bookmark, audio), name: "didReachBookmark:ofAudio:")
        let svgView = view.subviews[0] as SVGKImageView
        
        for (element, interval) in _elementIntervals {
            if interval ~= bookmark {
//                let layer = _image.layerWithIdentifier(element.getAttribute("id")) ??
//                    _image.layerWithIdentifier((element.parentNode as Element).getAttribute("id"))
//                
//                let nudgeUp = CGPoint(x: layer.position.x, y: layer.position.y - 20)
//                let anim = CABasicAnimation(keyPath: "position")
//                anim.fromValue = NSValue(CGPoint: layer.position)
//                anim.toValue = NSValue(CGPoint: nudgeUp)
//                anim.autoreverses = true
//                anim.duration = (interval.end - interval.start) * 0.4
//                anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
//                
//                layer.addAnimation(anim, forKey: "position")
            }
        }
    }
    
    func audioManager(manager: AudioManager, didBeginPlayingAudio audio: String, interval: AudioInterval?) {
        dump((audio, interval), name: "didBeginPlayingAudio:interval:")
    }
    
    func audioManager(manager: AudioManager, didStopPlayingAudio audio: String) {
        dump(audio, name: "didStopPlayingAudio:")
    }
}
