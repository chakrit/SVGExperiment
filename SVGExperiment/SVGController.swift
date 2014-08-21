import UIKit
import QuartzCore

class SVGController: UIViewController {
    private var _interactiveLayers: [CALayer] = []
    private var _activeLayers: [CALayer] = []

    let image: SVGKImage
    var imageView: SVGKImageView { return view as SVGKImageView }


    required init(coder aDecoder: NSCoder) { fatalError("initWithCoder() not supoprted.") }

    required init(imageName: String, nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        image = SVGKImage(named: imageName)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        loadLayerData()
    }


    override func loadView() {
        let v = SVGKImageView(SVGKImage: image)
        v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "didTapImage"))
        v.addConstraint(NSLayoutConstraint(item: v, width: image.size.width))
        v.addConstraint(NSLayoutConstraint(item: v, height: image.size.height))
        view = v
    }

    // After the SVG is fully loaded, we transfer all information stored in SVG attributes to the
    // associated CALayer instance for fast retreival and reference later and so we don't have to
    // touch the SVG DOM again.
    private func loadLayerData() {
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

                data.saveToLayer(layer)
                _interactiveLayers += [layer]
            }
        }

        loadLayerData_resolveInheritance(image.CALayerTree)
    }

    private func loadLayerData_resolveInheritance(layer: CALayer, var resolved: [String: Any] = [:]) {
        let d = LayerData.forLayer(layer)
        if d != nil {
            d!.audio = loadLayerData_resolve(&resolved, d!.audio, "audio")
            d!.interval = loadLayerData_resolve(&resolved, d!.interval, "interval")
            d!.animation = loadLayerData_resolve(&resolved, d!.animation, "animation")
        }

        for obj in layer.sublayers {
            let sublayer = obj as CALayer
            loadLayerData_resolveInheritance(sublayer, resolved: resolved)
        }
    }

    private func loadLayerData_resolve<T>(inout resolved: [String: Any], _ value: T?, _ key: String) -> T? {
        if let v = value {
            resolved[key] = v
            return v
        } else {
            return resolved[key] as? T
        }
    }


    func selectScope(scope: AudioScope) {
        let stillActive = _activeLayers.filter(layerShouldBeActive(scope))
        let activating = _interactiveLayers.filter(layerShouldBeActive(scope))
            .filter { find(stillActive, $0) == nil }
        let deactivating = _activeLayers.filter { !self.layerShouldBeActive(scope)(layer: $0) }

        for layer in deactivating { deactivateLayer(layer) }
        for layer in activating { activateLayer(layer) }
        _activeLayers = stillActive + activating

        // TODO: Fire scope change event.
    }

    private func layerShouldBeActive(scope: AudioScope) (layer: CALayer) -> Bool {
        if let d = LayerData.forLayer(layer) {
            if let i = d.interval {
                return scope.interval ~= i.start || scope.interval ~= i.end
            }
        }

        return false
    }

    private func activateLayer(layer: CALayer) {
        // TODO: Run layer animation
    }

    private func deactivateLayer(layer: CALayer) {
        // TODO: Run layer animation
    }

    
    private func parseInterval(rawStr: String) -> AudioInterval {
        let components = rawStr.componentsSeparatedByString("-")
        var start = Double(0.0), end = Double(0.0)
        NSScanner.localizedScannerWithString(components[0]).scanDouble(&start)
        NSScanner.localizedScannerWithString(components[1]).scanDouble(&end)
        
        return start...end
    }

    private func resolveLayerScope(layer: CALayer) -> AudioScope? {
        if let d = LayerData.forLayer(layer) {
            if d.audio != nil && d.interval != nil {
                return AudioScope(audio: d.audio!, interval: d.interval!)
            }
        }

        if let nearest = findNearestLayerWithData(layer) {
            return resolveLayerScope(nearest)
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


    private func didTapImage(sender: UITapGestureRecognizer!) {
        let point = sender.locationInView(imageView)
        let hitLayer = view.layer.hitTest(point)
        if hitLayer == nil { return }

        let layer = findNearestLayerWithData(hitLayer)
        if layer == nil { return }

        if let scope = resolveLayerScope(layer!) {
            selectScope(scope)
        }
    }
}
