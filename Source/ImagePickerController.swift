import UIKit

public class ImagePickerController: UIViewController {

  struct Dimensions {
    static let bottomContainerHeight: CGFloat = 108
  }

  lazy var galleryView: ImageGalleryView = { [unowned self] in
    let galleryView = ImageGalleryView()
    galleryView.backgroundColor = self.configuration.backgroundColor
    galleryView.setTranslatesAutoresizingMaskIntoConstraints(false)

    return galleryView
    }()

  lazy var bottomContainer: BottomContainerView = {
    let view = BottomContainerView()
    view.backgroundColor = UIColor(red:0.09, green:0.11, blue:0.13, alpha:1)
    view.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.delegate = self

    return view
    }()

  lazy var configuration: PickerConfiguration = {
    let configuration = PickerConfiguration()
    return configuration
    }()

  lazy var cameraController: CameraView = {
    let controller = CameraView()
    return controller
    }()

  public var doneButtonTitle: String? {
    didSet {
      bottomContainer.doneButton.setTitle(doneButtonTitle!, forState: .Normal)
    }
  }

  // MARK: - View lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.whiteColor()
    
    [galleryView, bottomContainer, cameraController.view].map { self.view.addSubview($0) }

    setupConstraints()
  }

  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    UIApplication.sharedApplication().statusBarHidden = true
  }

  public override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    galleryView.frame = CGRectMake(0,
      UIScreen.mainScreen().bounds.height - bottomContainer.frame.height - ImageGalleryView.Dimensions.galleryHeight,
      UIScreen.mainScreen().bounds.width,
      ImageGalleryView.Dimensions.galleryHeight)
    galleryView.updateFrames()
    cameraController.view.frame = CGRectMake(0, 32,
      UIScreen.mainScreen().bounds.width, galleryView.frame.origin.y - 32)
  }

  // MARK: - Autolayout

  func setupConstraints() {
    let attributes: [NSLayoutAttribute] = [.Bottom, .Right, .Width]

    attributes.map {
      self.view.addConstraint(NSLayoutConstraint(item: self.bottomContainer, attribute: $0,
        relatedBy: .Equal, toItem: self.view, attribute: $0,
        multiplier: 1, constant: 0))
    }

    view.addConstraint(NSLayoutConstraint(item: bottomContainer, attribute: .Height,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: Dimensions.bottomContainerHeight))
  }
}

// MARK: - Action methods

extension ImagePickerController: BottomContainerViewDelegate {

  func pickerButtonDidPress() { }

  func doneButtonDidPress() { }

  func cancelButtonDidPress() {
    dismissViewControllerAnimated(true, completion: nil)
  }

  func imageWrapperDidPress() { }
}
