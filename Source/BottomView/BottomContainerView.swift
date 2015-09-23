import UIKit

protocol BottomContainerViewDelegate: class {

  func pickerButtonDidPress()
  func doneButtonDidPress()
  func cancelButtonDidPress()
  func imageStackViewDidPress()
}

class BottomContainerView: UIView {

  lazy var pickerButton: ButtonPicker = { [unowned self] in
    let pickerButton = ButtonPicker()
    pickerButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    pickerButton.delegate = self

    return pickerButton
    }()

  lazy var borderPickerButton: UIView = {
    let view = UIView()
    view.backgroundColor = .clearColor()
    view.layer.borderColor = UIColor.whiteColor().CGColor
    view.layer.borderWidth = ButtonPicker.Dimensions.borderWidth
    view.layer.cornerRadius = ButtonPicker.Dimensions.buttonBorderSize / 2

    return view
    }()

  lazy var doneButton: UIButton = { [unowned self] in
    let button = UIButton()
    button.setTitle(self.configuration.cancelButtonTitle, forState: .Normal)
    button.titleLabel!.font = self.configuration.doneButton
    button.addTarget(self, action: "doneButtonDidPress:", forControlEvents: .TouchUpInside)

    return button
    }()

  lazy var stackView: ImageStackView = {
    let view = ImageStackView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
    return view
    }()
  lazy var configuration: PickerConfiguration = {
    let configuration = PickerConfiguration()
    return configuration
    }()

  lazy var topSeparator: UIView = { [unowned self] in
    let view = UIView()
    view.backgroundColor = self.configuration.backgroundColor

    return view
    }()

  lazy var tapGestureRecognizer: UITapGestureRecognizer = { [unowned self] in
    let gesture = UITapGestureRecognizer()
    gesture.addTarget(self, action: "handleTapGestureRecognizer:")

    return gesture
    }()

  weak var delegate: BottomContainerViewDelegate?
  var pastCount = 0

  // MARK: Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)

    for view in [borderPickerButton, pickerButton, doneButton, stackView, topSeparator] {
      addSubview(view)
      view.translatesAutoresizingMaskIntoConstraints = false
    }

    backgroundColor = configuration.backgroundColor
    stackView.addGestureRecognizer(tapGestureRecognizer)

    setupConstraints()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Action methods

  func doneButtonDidPress(button: UIButton) {
    if button.currentTitle == configuration.cancelButtonTitle {
      delegate?.cancelButtonDidPress()
    } else {
      delegate?.doneButtonDidPress()
    }
  }

  func handleTapGestureRecognizer(recognizer: UITapGestureRecognizer) {
    delegate?.imageStackViewDidPress()
  }

  private func animateImageView(imageView: UIImageView) {
    imageView.transform = CGAffineTransformMakeScale(0, 0)

    UIView.animateWithDuration(0.3, animations: {
      imageView.transform = CGAffineTransformMakeScale(1.05, 1.05)
      }, completion: { _ in
        UIView.animateWithDuration(0.2, animations: { _ in
          imageView.transform = CGAffineTransformIdentity
        })
    })
  }
}

// MARK: - ButtonPickerDelegate methods

extension BottomContainerView: ButtonPickerDelegate {

  func buttonDidPress() {
    delegate?.pickerButtonDidPress()
  }
}
