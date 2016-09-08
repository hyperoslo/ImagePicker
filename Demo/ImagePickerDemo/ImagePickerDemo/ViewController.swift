import UIKit
import ImagePicker
import Lightbox

class ViewController: UIViewController, ImagePickerDelegate {

  lazy var button: UIButton = self.makeButton()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.whiteColor()
    view.addSubview(button)
    button.translatesAutoresizingMaskIntoConstraints = false

    view.addConstraint(NSLayoutConstraint(item: button, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0))
    view.addConstraint(NSLayoutConstraint(item: button, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0))
  }

  func makeButton() -> UIButton {
    let button = UIButton()
    button.setTitle("Show ImagePicker", forState: .Normal)
    button.setTitleColor(UIColor.blackColor(), forState: .Normal)
    button.addTarget(self, action: #selector(buttonTouched(_:)), forControlEvents: .TouchUpInside)

    return button
  }

  func buttonTouched(button: UIButton) {
    let imagePicker = ImagePickerController()
    imagePicker.delegate = self

    presentViewController(imagePicker, animated: true, completion: nil)
  }

  // MARK: - ImagePickerDelegate

  func cancelButtonDidPress(imagePicker: ImagePickerController) {
    imagePicker.dismissViewControllerAnimated(true, completion: nil)
  }

  func wrapperDidPress(imagePicker: ImagePickerController, images: [UIImage]) {
    guard images.count > 0 else { return }

    let lightboxImages = images.map {
      return LightboxImage(image: $0)
    }

    let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
    imagePicker.presentViewController(lightbox, animated: true, completion: nil)
  }

  func doneButtonDidPress(imagePicker: ImagePickerController, images: [UIImage]) {
    imagePicker.dismissViewControllerAnimated(true, completion: nil)
  }
}
