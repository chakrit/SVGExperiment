import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        let frame = UIScreen.mainScreen().bounds
        let w = UIWindow(frame: frame)
        w.rootViewController = RootViewController()
        w.makeKeyAndVisible()

        window = w
        return true
    }

    func applicationWillResignActive(application: UIApplication!) { }
    func applicationDidEnterBackground(application: UIApplication!) { }
    func applicationWillEnterForeground(application: UIApplication!) { }
    func applicationDidBecomeActive(application: UIApplication!) { }
    func applicationWillTerminate(application: UIApplication!) { }
}

