import UIKit

class RootViewController: UIViewController {
    typealias ImageView = SVGKFastImageView

    override func loadView() {
        var screenSize = UIScreen.mainScreen().bounds.size
        if screenSize.height > screenSize.width {
            screenSize = CGSize(width: screenSize.height, height: screenSize.width)
        }

        let frame = CGRect(origin: CGPointZero, size: screenSize)

        let v = UIView(frame: frame)
        v.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        v.backgroundColor = .whiteColor()

        let contentSize = CGSize(width: 1024, height: 630)
        let svgFrame = CGRect(origin: CGPointZero, size: contentSize)

        let svg = ImageView(frame: svgFrame)
        svg.setTranslatesAutoresizingMaskIntoConstraints(false)
        svg.backgroundColor = .whiteColor()
        svg.contentMode = .ScaleAspectFit
        svg.image = SVGKImage(named: "Twinkle.svg")

        v.addSubview(svg)
        v.addConstraint(NSLayoutConstraint(horizontalAlignItem: svg, withItem: v))
        v.addConstraint(NSLayoutConstraint(verticalAlignItem: svg, withItem: v))
        v.addConstraint(NSLayoutConstraint(item: svg, width: contentSize.width))
        v.addConstraint(NSLayoutConstraint(item: svg, height: contentSize.height))
        
        view = v
    }
}
