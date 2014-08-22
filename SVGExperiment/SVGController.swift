import UIKit
import QuartzCore

// TODO: Move PlayheadController implementation into an extension.
class SVGController: UIViewController, PlayheadController {
    private var _interactiveLayers: [CALayer] = []
    private var _activeLayers: [CALayer] = []
    private var _playhead: Playhead = Playhead()

    let image: SVGKImage
    var imageView: SVGKImageView { return view as SVGKImageView }
    
    var onPlayheadChanged: OnPlayheadChangeHandler?
    var playhead: Playhead {
        get { return _playhead }
        set { updatePlayhead(newValue) }
    }
    
    var canPlay: Bool { return false }
    var canPause: Bool { return false }


    required init(coder aDecoder: NSCoder) { fatalError("initWithCoder() not supported.") }

    required init(imageName: String, nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        image = SVGKImage(named: imageName)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        loadLayerData()
    }


    override func loadView() {
        let v = SVGKLayeredImageView(SVGKImage: image)
        v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "didTapImage:"))
        v.addConstraint(NSLayoutConstraint(item: v, width: image.size.width))
        v.addConstraint(NSLayoutConstraint(item: v, height: image.size.height))
        view = v
    }

    private func loadLayerData() {
        // TODO: Inner functions are problematic as of current Xcode beta so we're writing standard
        //   instance methods for the time being.
        loadLayerData_init()
        loadLayerData_resolveInheritance(image.CALayerTree)
    }

    // After the SVG is fully loaded, we transfer all information stored in SVG attributes to the
    // associated CALayer instance for fast retreival and reference later and so we don't have to
    // touch the SVG DOM again.
    private func loadLayerData_init() {
        _interactiveLayers = []

        let allElements = image.DOMTree.getElementsByTagName("*")
        for var i = 0; i < allElements.length; i++ {
            let elem = allElements.item(Int32(i)) as Element
            let id = elem.getAttribute("id")
            if id == nil { continue }
    
            if let layer = image.layerWithIdentifier(id) {
                let data = LayerData()
                data.id = id
                data.audio = elem.getAttribute("audio")
                data.interval = elem.hasAttribute("interval") ? parseInterval(elem.getAttribute("interval")) : nil
                data.animation = elem.getAttribute("animation")
                
                // Ignore elements without any associated animation data.
                if !(data.audio == nil && data.interval == nil && data.animation == nil) {
                    data.id = id
                    data.saveToLayer(layer)
                    _interactiveLayers += [layer]
                }
            }
        }
    }

    // Attributes specified on elements (except for id) should be inherited down the chain. This
    // method resolves the inherited values from top-down. Note that Swift dictionaries are struct
    // so have value semantic by default.
    private func loadLayerData_resolveInheritance(layer: CALayer, var resolved: [String: Any] = [:]) {
        let d = LayerData.forLayer(layer)
        if d != nil {
            d!.audio = loadLayerData_resolve(&resolved, d!.audio, "", "audio")
            d!.interval = loadLayerData_resolve(&resolved, d!.interval, 0...0, "interval")
            d!.animation = loadLayerData_resolve(&resolved, d!.animation, "", "animation")
        }
        
        if let sublayers = layer.sublayers {
            for obj in sublayers {
                if let sublayer = obj as? CALayer {
                    loadLayerData_resolveInheritance(sublayer, resolved: resolved)
                }
            }
        }
    }

    private func loadLayerData_resolve<T: Equatable>(inout resolved: [String: Any], _ value: T?, _ zeroValue: T, _ key: String) -> T? {
        if let v = value {
            if v != zeroValue {
                resolved[key] = v
                return v
            }
        }
        
        return resolved[key] as? T
    }

    
    func play() { fatalError("SVGController does not support play()") }
    func pause() { fatalError("SVGController does not support pause()") }

    private func updatePlayhead(playhead: Playhead) {
        let stillActive = _activeLayers.filter(layerShouldBeActive(playhead))
        let activating = _interactiveLayers.filter(layerShouldBeActive(playhead))
            .filter { find(stillActive, $0) == nil }
        let deactivating = _activeLayers.filter { !self.layerShouldBeActive(playhead)(layer: $0) }

        for layer in deactivating { deactivateLayer(layer) }
        for layer in activating { activateLayer(layer) }
        _activeLayers = stillActive + activating

        _playhead = playhead
        onPlayheadChanged?()
    }

    private func layerShouldBeActive(playhead: Playhead) (layer: CALayer) -> Bool {
        if let d = LayerData.forLayer(layer) {
            if let i = d.interval {
                return i ~= playhead.time
            }
        }

        return false
    }

    private func activateLayer(layer: CALayer) {
        // TODO: Run layer animation
        let d = LayerData.forLayer(layer)
        if d == nil { return }

        let a = d!.animation
        if a == nil { return }

        switch a! {
        case "bounce":
            let anim = CABasicAnimation(keyPath: "position")
            anim.fromValue = NSValue(CGPoint: layer.position)
            anim.toValue = NSValue(CGPoint: CGPoint(x: layer.position.x, y: layer.position.y - 20))
            anim.autoreverses = true
            if let i = d!.interval {
                anim.duration = (i.end - i.start) * 0.5
            } else {
                anim.duration = 0.5
            }

            layer.addAnimation(anim, forKey: "position")

        default:
            dump(d!.animation, name: "unknown animation")
        }
    }

    private func deactivateLayer(layer: CALayer) {
        // TODO: Fast-forward all animations (which should have autoreverses = true?)
    }

    
    private func parseInterval(rawStr: String) -> AudioInterval {
        let components = rawStr.componentsSeparatedByString("-")
        var start = Double(0.0), end = Double(0.0)
        NSScanner.localizedScannerWithString(components[0]).scanDouble(&start)
        NSScanner.localizedScannerWithString(components[1]).scanDouble(&end)
        
        return start...end
    }

    private func resolveLayerPlayhead(layer: CALayer) -> Playhead? {
        if let d = LayerData.forLayer(layer) {
            if d.audio != nil && d.interval != nil {
                return Playhead(audio: d.audio!,
                    time: d.interval!.start,
                    stopTime: d.interval!.end)
            }
        }

        if let nearest = findNearestLayerWithData(layer) {
            return resolveLayerPlayhead(nearest)
        } else {
            return nil
        }
    }

    private func findNearestLayerWithData(layer: CALayer) -> CALayer? {
        if let d = LayerData.forLayer(layer) { return layer }

        if let parent = layer.superlayer {
            return findNearestLayerWithData(parent)
        } else {
            return nil
        }
    }


    // TODO: private
    func didTapImage(sender: UITapGestureRecognizer!) {
        let point = sender.locationInView(imageView)
        
        let hitLayer = image.CALayerTree.hitTest(point)
        if hitLayer == nil { return }

        let layer = findNearestLayerWithData(hitLayer)
        if layer == nil { return }

        if let playhead = resolveLayerPlayhead(layer!) {
            updatePlayhead(playhead)
        }
    }
}
