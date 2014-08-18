import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    private var _window: UIWindow? = nil

    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        let frame = UIScreen.mainScreen().bounds
        let w = UIWindow(frame: frame)
        w.rootViewController = RootViewController()
        w.makeKeyAndVisible()

        _window = w
        return true
    }
}

