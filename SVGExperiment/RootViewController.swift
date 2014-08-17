import UIKit

class RootViewController: UIViewController {
    override func loadView() {
        let v = UIView(frame: CGRectZero)
        v.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        v.backgroundColor = .whiteColor()

        view = v
    }
}
