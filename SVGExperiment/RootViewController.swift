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
        v.addConstraint(NSLayoutConstraint(item: svg, attribute: .CenterX,
            relatedBy: .Equal, toItem: v, attribute: .CenterX,
            multiplier: 1.0, constant: 0.0))
        v.addConstraint(NSLayoutConstraint(item: svg, attribute: .CenterY,
            relatedBy: .Equal, toItem: v, attribute: .CenterY,
            multiplier: 1.0, constant: 0.0))
        svg.addConstraint(NSLayoutConstraint(item: svg, attribute: .Width,
            relatedBy: .Equal, toItem: nil, attribute: .Width,
            multiplier: 1.0, constant: contentSize.width))
        svg.addConstraint(NSLayoutConstraint(item: svg, attribute: .Height,
            relatedBy: .Equal, toItem: nil, attribute: .Height,
            multiplier: 1.0, constant: contentSize.height))

        view = v
    }
}
