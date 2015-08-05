import UIKit

protocol BottomContainerViewDelegate {

  func pickerButtonDidPress()
  func doneButtonDidPress()
  func cancelButtonDidPress()
  func imageWrapperDidPress()
}

class BottomContainerView: UIView {

  lazy var pickerButton: ButtonPicker = {
    let pickerButton = ButtonPicker()
    pickerButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    pickerButton.setTranslatesAutoresizingMaskIntoConstraints(false)

    return pickerButton
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

  lazy var doneButton: UIButton = { [unowned self] in
    let button = UIButton()
    button.setTitle(self.configuration.cancelButtonTitle, forState: .Normal)
    button.titleLabel!.font = self.configuration.doneButton
    button.addTarget(self, action: "doneButtonDidPress:", forControlEvents: .TouchUpInside)
    button.setTranslatesAutoresizingMaskIntoConstraints(false)

    return button
    }()

  lazy var imageWrapper: ImageWrapper = {
    let view = ImageWrapper()
    view.setTranslatesAutoresizingMaskIntoConstraints(false)

    return view
    }()

  lazy var configuration: PickerConfiguration = {
    let configuration = PickerConfiguration()
    return configuration
    }()

  var delegate: BottomContainerViewDelegate?

  // MARK: Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)

    [borderPickerButton, pickerButton, doneButton, imageWrapper].map { self.addSubview($0) }

    setupConstraints()
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Autolayout

  func setupConstraints() {
    let attributesBorder: [NSLayoutAttribute] = [.CenterX, .CenterY]

    attributesBorder.map {
      self.addConstraint(NSLayoutConstraint(item: self.pickerButton, attribute: $0,
        relatedBy: .Equal, toItem: self, attribute: $0,
        multiplier: 1, constant: 0))
    }

    addConstraint(NSLayoutConstraint(item: pickerButton, attribute: .Width,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: ButtonPicker.Dimensions.buttonSize))

    addConstraint(NSLayoutConstraint(item: pickerButton, attribute: .Height,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: ButtonPicker.Dimensions.buttonSize))

    attributesBorder.map {
      self.addConstraint(NSLayoutConstraint(item: self.borderPickerButton, attribute: $0,
        relatedBy: .Equal, toItem: self, attribute: $0,
        multiplier: 1, constant: 0))
    }

    addConstraint(NSLayoutConstraint(item: borderPickerButton, attribute: .Width,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: ButtonPicker.Dimensions.buttonBorderSize))

    addConstraint(NSLayoutConstraint(item: borderPickerButton, attribute: .Height,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: ButtonPicker.Dimensions.buttonBorderSize))

    addConstraint(NSLayoutConstraint(item: doneButton, attribute: .CenterY,
      relatedBy: .Equal, toItem: self, attribute: .CenterY,
      multiplier: 1, constant: 0))

    addConstraint(NSLayoutConstraint(item: doneButton, attribute: .CenterX,
      relatedBy: .Equal, toItem: self, attribute: .Right,
      multiplier: 1, constant: -(UIScreen.mainScreen().bounds.width - (ButtonPicker.Dimensions.buttonBorderSize + UIScreen.mainScreen().bounds.width)/2)/2))

    addConstraint(NSLayoutConstraint(item: imageWrapper, attribute: .Width,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: ImageWrapper.Dimensions.imageSize))

    addConstraint(NSLayoutConstraint(item: imageWrapper, attribute: .Height,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: ImageWrapper.Dimensions.imageSize))

    addConstraint(NSLayoutConstraint(item: imageWrapper, attribute: .CenterY,
      relatedBy: .Equal, toItem: self, attribute: .CenterY,
      multiplier: 1, constant: 0))

    addConstraint(NSLayoutConstraint(item: imageWrapper, attribute: .CenterX,
      relatedBy: .Equal, toItem: self, attribute: .Left,
      multiplier: 1, constant: UIScreen.mainScreen().bounds.width/4 - ButtonPicker.Dimensions.buttonBorderSize/4))
  }

  // MARK: - Action methods

  func doneButtonDidPress(button: UIButton) {
    if button.currentTitle == configuration.cancelButtonTitle {
      delegate?.cancelButtonDidPress()
    } else {
      delegate?.doneButtonDidPress()
    }
  }

  // MARK: - Wrapper methods

  func updateWrapperImages(array: NSMutableArray) {
    switch array.count {
    case 1:
      imageWrapper.firstImageView.image = array.firstObject as? UIImage
      imageWrapper.secondImageView.image = nil
      imageWrapper.secondImageView.alpha = 0
    case 0:
      imageWrapper.firstImageView.image = nil
      imageWrapper.secondImageView.image = nil
    case 2:
      imageWrapper.firstImageView.image = array[0] as? UIImage
      imageWrapper.secondImageView.image = array[1] as? UIImage
      imageWrapper.secondImageView.alpha = 1
      imageWrapper.thirdImageView.alpha = 0
    case 3:
      imageWrapper.firstImageView.image = array[0] as? UIImage
      imageWrapper.secondImageView.image = array[1] as? UIImage
      imageWrapper.thirdImageView.image = array[2] as? UIImage
      imageWrapper.thirdImageView.alpha = 1
      imageWrapper.fourthImageView.alpha = 0
    default:
      imageWrapper.fourthImageView.alpha = 1
      imageWrapper.firstImageView.image = array[array.count - 4] as? UIImage
      imageWrapper.secondImageView.image = array[array.count - 3] as? UIImage
      imageWrapper.thirdImageView.image = array[array.count - 2] as? UIImage
      imageWrapper.fourthImageView.image = array.lastObject as? UIImage
    }

    pickerButton.photoNumber = array.count
  }
}

// MARK: - ButtonPickerDelegate methods

extension BottomContainerView: ButtonPickerDelegate {

  func buttonDidPress() {
    delegate?.pickerButtonDidPress()
  }
}

// MARK: - ImageWrapperDelegate methods

extension BottomContainerView: ImageWrapperDelegate {

  func imageWrapperDidPress() {
    delegate?.imageWrapperDidPress()
  }
}
