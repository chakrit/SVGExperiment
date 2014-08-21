import UIKit

@objc class LayerData: NSObject {
    var id: String? = nil
    var audio: String? = nil
    var animation: String? = nil
    var interval: AudioInterval? = nil

    // TODO: Extension on CALayer crashes the editor so often it's annoying so I'm making these
    //   a standard/simple method instead.
    class func forLayer(layer: CALayer) -> LayerData? {
        return layer.valueForKey("LanguageBook-data") as LayerData?
    }

    func saveToLayer(layer: CALayer) {
        layer.setValue(self, forKey: "LanguageBook-data")
    }
}
