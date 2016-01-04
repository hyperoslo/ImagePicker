import UIKit
import ImagePicker

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  lazy var imagePickerController: ImagePickerController = ImagePickerController()
  lazy var window: UIWindow? = UIWindow(frame: UIScreen.mainScreen().bounds)

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    window?.rootViewController = imagePickerController
    window?.makeKeyAndVisible()
    
    return true
  }
}
