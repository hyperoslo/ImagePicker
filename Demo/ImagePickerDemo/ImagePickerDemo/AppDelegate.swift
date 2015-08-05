import UIKit
import ImagePicker

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  lazy var imagePickerController: ImagePickerController = {
    let imagePickerController = ImagePickerController()
    return imagePickerController
    }()

  lazy var window: UIWindow? = {
    let window = UIWindow(frame: UIScreen.mainScreen().bounds)
    return window
    }()

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    window?.rootViewController = imagePickerController
    window?.makeKeyAndVisible()
    
    return true
  }
}

