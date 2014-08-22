import UIKit
import QuartzCore

class RootViewController: UIViewController {
    let audioManager: AudioManager
    let svgController: SVGController
    let sliderController: SliderController
    let synchronizer: PlayheadSynchronizer
    
    convenience override init() { self.init(nibName: nil, bundle: nil) }
    required init(coder aDecoder: NSCoder) { fatalError("initWithCoder not supported.") }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        audioManager = AudioManager()
        svgController = SVGController(imageName: "twinkle.svg",
            nibName: nibNameOrNil,
            bundle: nibBundleOrNil)
        sliderController = SliderController()
        
        synchronizer = PlayheadSynchronizer(controllers: audioManager, svgController, sliderController)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    override func loadView() {
        var screenSize = UIScreen.mainScreen().bounds.size
        if screenSize.height > screenSize.width {
            screenSize = CGSize(width: screenSize.height, height: screenSize.width)
        }
        
        let size = screenSize
        let frame = CGRect(origin: CGPointZero, size: size)
        let v = UIView(frame: frame)
        v.backgroundColor = .whiteColor()

        let svg = svgController.view
        svg.frame = CGRect(origin: CGPointZero, size: size)
        svg.setTranslatesAutoresizingMaskIntoConstraints(false)
        svg.backgroundColor = .whiteColor()
        
        v.addSubview(svg)
        v.addConstraint(NSLayoutConstraint(horizontalAlignItem: svg, withItem: v))
        v.addConstraint(NSLayoutConstraint(verticalAlignItem: svg, withItem: v))
            
        let slider = sliderController.view
        slider.frame = CGRect(origin: CGPointZero, size: CGSize(width: 400, height: 44))
        slider.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        v.addSubview(slider)
        v.addConstraint(NSLayoutConstraint(horizontalAlignItem: slider, withItem: v))
        v.addConstraint(NSLayoutConstraint(bottomAnchor: slider, toItem: v, padding: -10.0))
            
        view = v
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioManager.playhead = Playhead(audio: "twinkle.mp3", time: 0, stopTime: 0)
        audioManager.play()
    }
}
