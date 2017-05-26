import UIKit
import TouchVisualizer

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate  {

  var window: UIWindow?

  fileprivate lazy var builder: AppBuilder = {
    return AppBuilder()
  }()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    var config = Configuration()
    config.color = .red
    Visualizer.start(config)
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = builder.makeAppNavigationController()
    window.makeKeyAndVisible()
    self.window = window
    return true
  }
}
