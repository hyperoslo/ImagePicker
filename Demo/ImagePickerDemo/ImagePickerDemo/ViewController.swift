import UIKit
import ImagePicker
import CoreLocation

class ViewController: UIViewController, ImagePickerDelegate {

  lazy var button: UIButton = self.makeButton()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.white
    view.addSubview(button)
    button.translatesAutoresizingMaskIntoConstraints = false

    view.addConstraint(NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
    view.addConstraint(NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0))
  }

  func makeButton() -> UIButton {
    let button = UIButton()
    button.setTitle("Show ImagePicker", for: UIControlState())
    button.setTitleColor(UIColor.black, for: UIControlState())
    button.addTarget(self, action: #selector(buttonTouched(_:)), for: .touchUpInside)

    return button
  }

  func buttonTouched(_ button: UIButton) {
    let imagePicker = ImagePickerController()
    imagePicker.delegate = self

    present(imagePicker, animated: true, completion: nil)
  }

  // MARK: - ImagePickerDelegate

  func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
    imagePicker.dismiss(animated: true, completion: nil)
  }
  
  

  func wrapperDidPress(_ imagePicker: ImagePickerController, images: [(image: UIImage,location: CLLocation?)]) {
    guard images.count > 0 else { return }

//    let lightboxImages = images.map { image, location in
//      return image
//    }

//    let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
//    imagePicker.presentViewController(lightbox, animated: true, completion: nil)
  }

  func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [(image: UIImage,location: CLLocation?)]) {
    
    imagePicker.dismiss(animated: true, completion: nil)
    
  }
}
