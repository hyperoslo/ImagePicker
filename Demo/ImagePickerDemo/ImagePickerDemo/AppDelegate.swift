import UIKit
import ImagePicker
import Lightbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ImagePickerDelegate {

  lazy var imagePickerController: ImagePickerController = ImagePickerController()
  lazy var window: UIWindow? = UIWindow(frame: UIScreen.mainScreen().bounds)

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    imagePickerController.delegate = self

    window?.rootViewController = imagePickerController
    window?.makeKeyAndVisible()
    
    return true
  }

  // MARK: - ImagePickerDelegate

  func cancelButtonDidPress(imagePicker: ImagePickerController) {

  }

  func wrapperDidPress(imagePicker: ImagePickerController, images: [UIImage]) {
    let lightboxImages = images.map {
      return LightboxImage(image: $0)
    }

    let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
    window?.rootViewController?.presentViewController(lightbox, animated: true, completion: nil)
  }

  func doneButtonDidPress(imagePicker: ImagePickerController, images: [UIImage]) {

  }
}
