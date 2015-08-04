import UIKit

public class ImagePickerController: UIViewController {

  struct Dimensions {
    static let bottomContainerHeight: CGFloat = 108
  }

  lazy var galleryView: ImageGalleryView = {
    let galleryView = ImageGalleryView()
    return galleryView
    }()

  lazy var borderPickerButton: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.clearColor()
    view.layer.borderColor = UIColor.whiteColor().CGColor
    view.layer.borderWidth = ButtonPicker.Dimensions.borderWidth
    view.layer.cornerRadius = ButtonPicker.Dimensions.buttonBorderSize / 2
    view.setTranslatesAutoresizingMaskIntoConstraints(false)

    return view
    }()

  lazy var pickerButton: ButtonPicker = {
    let pickerButton = ButtonPicker()
    pickerButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    pickerButton.delegate = self

    return pickerButton
    }()

  lazy var doneButton: UIButton = {
    let button = UIButton()
    return button
    }()

  lazy var bottomContainer: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.blackColor()
    view.setTranslatesAutoresizingMaskIntoConstraints(false)

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

    [bottomContainer].map { self.view.addSubview($0) }
    [borderPickerButton, pickerButton].map { self.bottomContainer.addSubview($0) }

    setupConstraints()
  }

  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    UIApplication.sharedApplication().statusBarHidden = true
  }

  // MARK: - Autolayout

  func setupConstraints() {
    let attributes: [NSLayoutAttribute] = [.Bottom, .Right, .Width]
    let attributesBorder: [NSLayoutAttribute] = [.CenterX, .CenterY]

    attributes.map {
      self.view.addConstraint(NSLayoutConstraint(item: self.bottomContainer, attribute: $0,
        relatedBy: .Equal, toItem: self.view, attribute: $0,
        multiplier: 1, constant: 0))
    }

    view.addConstraint(NSLayoutConstraint(item: self.bottomContainer, attribute: .Height,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: Dimensions.bottomContainerHeight))

    attributesBorder.map {
      self.view.addConstraint(NSLayoutConstraint(item: self.pickerButton, attribute: $0,
        relatedBy: .Equal, toItem: self.bottomContainer, attribute: $0,
        multiplier: 1, constant: 0))
    }

    view.addConstraint(NSLayoutConstraint(item: self.pickerButton, attribute: .Width,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: ButtonPicker.Dimensions.buttonSize))

    view.addConstraint(NSLayoutConstraint(item: self.pickerButton, attribute: .Height,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: ButtonPicker.Dimensions.buttonSize))

    attributesBorder.map {
      self.view.addConstraint(NSLayoutConstraint(item: self.borderPickerButton, attribute: $0,
        relatedBy: .Equal, toItem: self.bottomContainer, attribute: $0,
        multiplier: 1, constant: 0))
    }

    view.addConstraint(NSLayoutConstraint(item: self.borderPickerButton, attribute: .Width,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: ButtonPicker.Dimensions.buttonBorderSize))

    view.addConstraint(NSLayoutConstraint(item: self.borderPickerButton, attribute: .Height,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: ButtonPicker.Dimensions.buttonBorderSize))
  }
}

extension ImagePickerController: ButtonPickerDelegate {

  func buttonDidPress() {
    // TODO: Handle button actions
  }
}
