import UIKit

public class ImagePickerController: UIViewController {

  lazy var galleryView: ImageGalleryView = {
    let galleryView = ImageGalleryView()
    return galleryView
    }()

  lazy var pickerButton: ButtonPicker = {
    let pickerButton = ButtonPicker()
    return pickerButton
    }()

  lazy var doneButton: UIButton = {
    let button = UIButton()
    return button
    }()

  lazy var bottomContainer: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.blackColor()

    return view
    }()

  public var doneButtonTitle: String? {
    didSet {
      doneButton.setTitle(doneButtonTitle!, forState: .Normal)
    }
  }

  // MARK: - View lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    setupConstraints()
  }

  // MARK: - Autolayout

  func setupConstraints() {
    
  }
}
