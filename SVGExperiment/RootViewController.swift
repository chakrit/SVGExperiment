import UIKit

class RootViewController: UIViewController {
    typealias ImageView = SVGKLayeredImageView

    override func loadView() {
        var screenSize = UIScreen.mainScreen().bounds.size
        if screenSize.height > screenSize.width {
            screenSize = CGSize(width: screenSize.height, height: screenSize.width)
        }

        let frame = CGRect(origin: CGPointZero, size: screenSize)
        let v = UIView(frame: frame)
        v.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        v.backgroundColor = .whiteColor()

        let image = SVGKImage(named: "twinkle.svg")
        
        let svgFrame = CGRect(origin: CGPointZero, size: image.size)
        let svg = ImageView(frame: svgFrame)
        svg.setTranslatesAutoresizingMaskIntoConstraints(false)
        svg.backgroundColor = .whiteColor()
        svg.contentMode = .ScaleAspectFit
        svg.image = image
        v.addSubview(svg)

        v.addConstraint(NSLayoutConstraint(horizontalAlignItem: svg, withItem: v))
        v.addConstraint(NSLayoutConstraint(verticalAlignItem: svg, withItem: v))
        v.addConstraint(NSLayoutConstraint(item: svg, width: image.size.width))
        v.addConstraint(NSLayoutConstraint(item: svg, height: image.size.height))
        view = v
    }
}
