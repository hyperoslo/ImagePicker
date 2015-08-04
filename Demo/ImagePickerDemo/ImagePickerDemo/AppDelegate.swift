import UIKit
import ImagePicker

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  lazy var imagePickerController: ImagePickerController = {
    let imagePickerController = ImagePickerController()
    return imagePickerController
    }()

  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    window?.rootViewController = imagePickerController
    window?.makeKeyAndVisible()
    
    return true
  }
}

