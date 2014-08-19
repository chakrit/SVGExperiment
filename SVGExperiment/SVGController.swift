import UIKit
import QuartzCore

@objc class AudioScope {
    let audio: String
    let interval: AudioInterval

    init(audio: String, interval: AudioInterval) {
        self.audio = audio
        self.interval = interval
    }
}

@objc protocol SVGControllerDelegate: class {
    optional func svgController(controller: SVGController, didSelectScope scope: AudioScope)
}

// TODO: Use these sync-ing protocol instead:
@objc protocol ScopableDelegate: class {
    optional func scopableObject(object: Scopable, didChangeToScope scope: AudioScope)
}

@objc protocol Scopable: class {
    weak var scopeDelegate: ScopableDelegate? { get set }
    func selectScope(scope: AudioScope)
}

class SVGController: UIViewController {
    private enum K: String {
        case LayerId = "SVGExperiment.Id"

        func __conversion() -> String { return self.toRaw() }
    }


    private var _layerByIds: [String: CALayer] = [:]

    let image: SVGKImage
    var imageView: SVGKImageView { return view as SVGKImageView }


    required init(coder aDecoder: NSCoder!) { fatalError("initWithCoder() not supoprted.") }

    required init(imageName: String, nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        image = SVGKImage(named: imageName)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }


    override func loadView() {
        let v = SVGKImageView(SVGKImage: image)
        v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "didTapImage"))
        v.addConstraint(NSLayoutConstraint(item: v, width: image.size.width))
        v.addConstraint(NSLayoutConstraint(item: v, height: image.size.height))
        view = v
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Our touch detection system returns a CALayer so we're tagging each layer with their
        // corresponding element's ID for fast retreival later.
        let allElements = image.DOMTree.getElementsByTagName("*")
        for var i = 0; i < allElements.length; i++ {
            let elem = allElements.item(Int32(i)) as Element
            let id = elem.getAttribute("id")
            if id == nil { continue }

            let layer = image.layerWithIdentifier(id)
            layer.setValue(id, forKey: K.LayerId)
            // TODO: Put scope data into the layer and files
        }
    }


    func selectScope(scope: AudioScope) { }
    private func collectScopeInformation(layer: CALayer) -> AudioScope {
    }


    private func didTapImage(sender: UITapGestureRecognizer!) {
        let point = sender.locationInView(imageView)
        let layer = view.layer.hitTest(point)
        if layer == nil { return }

        let id = layer.valueForKey(K.LayerId) as String!
        if id != nil && id != "" {
            let element = image.DOMTree.getElementById(id)
            if element != nil {
                didTapElement(element)
            }
        }
    }

    private func didTapElement(element: Element) {
    }
}
