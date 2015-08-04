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

  public var doneButtonTitle: String? {
    didSet {
      bottomContainer.doneButton.setTitle(doneButtonTitle!, forState: .Normal)
    }
  }

  // MARK: - View lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.whiteColor()
    
    [bottomContainer, galleryView].map { self.view.addSubview($0) }

    setupConstraints()
  }

  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    UIApplication.sharedApplication().statusBarHidden = true
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

    view.addConstraint(NSLayoutConstraint(item: galleryView, attribute: .Width,
      relatedBy: .Equal, toItem: view, attribute: .Width,
      multiplier: 1, constant: 0))

    view.addConstraint(NSLayoutConstraint(item: galleryView, attribute: .Height,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: ImageGalleryView.Dimensions.galleryHeight))

    view.addConstraint(NSLayoutConstraint(item: galleryView, attribute: .Right,
      relatedBy: .Equal, toItem: view, attribute: .Right,
      multiplier: 1, constant: 0))

    view.addConstraint(NSLayoutConstraint(item: galleryView, attribute: .Bottom,
      relatedBy: .Equal, toItem: bottomContainer, attribute: .Top,
      multiplier: 1, constant: 0))
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
