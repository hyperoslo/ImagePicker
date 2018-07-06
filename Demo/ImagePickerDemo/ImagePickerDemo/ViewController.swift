import UIKit
import ImagePicker
import Lightbox
import CoreLocation
import AVFoundation


class ViewController: UIViewController, ImagePickerDelegate {

  lazy var button: UIButton = self.makeButton()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.white
    view.addSubview(button)
    button.translatesAutoresizingMaskIntoConstraints = false

    view.addConstraint(
      NSLayoutConstraint(item: button, attribute: .centerX,
                         relatedBy: .equal, toItem: view,
                         attribute: .centerX, multiplier: 1,
                         constant: 0))

    view.addConstraint(
      NSLayoutConstraint(item: button, attribute: .centerY,
                         relatedBy: .equal, toItem: view,
                         attribute: .centerY, multiplier: 1,
                         constant: 0))
  }

  func makeButton() -> UIButton {
    let button = UIButton()
    button.setTitle("Show ImagePicker", for: .normal)
    button.setTitleColor(UIColor.black, for: .normal)
    button.addTarget(self, action: #selector(buttonTouched(button:)), for: .touchUpInside)

    return button
  }

  @objc func buttonTouched(button: UIButton) {
    let config = Configuration()
    config.doneButtonTitle = "Finish"
    config.noImagesTitle = "Sorry! There are no images here!"
    config.recordLocation = false
    config.allowVideoSelection = true

    let imagePicker = ImagePickerController(configuration: config)
    imagePicker.delegate = self
    ImagePickerController.photoQuality = AVCaptureSession.Preset.photo


    present(imagePicker, animated: true, completion: nil)
  }

  // MARK: - ImagePickerDelegate

  func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
    imagePicker.dismiss(animated: true, completion: nil)
  }

  func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
    guard images.count > 0 else { return }

    let lightboxImages = images.map {
      return LightboxImage(image: $0)
    }

    let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
    imagePicker.present(lightbox, animated: true, completion: nil)
  }

  func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
    imagePicker.dismiss(animated: true, completion: nil)
  }

  // Called only if set value to ImagePickerController.photoQuality
  func wrapperDidPress(_ imagePicker: ImagePickerController, images: [(imageData: Data, location: CLLocation?)]) {
    guard images.count > 0 else { return }

    self.parseImageData(imagePicker: imagePicker, images: images)
  }
  // Called only if set value to ImagePickerController.photoQuality
  func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [(imageData: Data, location: CLLocation?)]) {
    guard images.count > 0 else { return }

    self.parseImageData(imagePicker: imagePicker, images: images)
  }

  private func parseImageData(imagePicker: ImagePickerController, images: [(imageData: Data, location: CLLocation?)]) {

    var lightboxImages = [LightboxImage]()

    images.forEach { (image) in
      print(image.location as Any)
      if let image = UIImage(data: image.imageData, scale: 1.0) {
        lightboxImages.append(LightboxImage(image: image))
      }
      let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
      imagePicker.present(lightbox, animated: true, completion: nil)
    }
  }

}
