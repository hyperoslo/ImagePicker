import UIKit

protocol BottomContainerViewDelegate: class {

  func pickerButtonDidPress()
  func doneButtonDidPress()
  func cancelButtonDidPress()
  func imageStackViewDidPress()
}

open class BottomContainerView: UIView {

  struct Dimensions {
    static let height: CGFloat = 101
  }

  var configuration = ImagePickerConfiguration()

  lazy var pickerButton: ButtonPicker = { [unowned self] in
    let pickerButton = ButtonPicker(configuration: self.configuration)
    pickerButton.setTitleColor(UIColor.white, for: UIControl.State())
    pickerButton.delegate = self
    pickerButton.numberLabel.isHidden = !self.configuration.showsImageCountLabel

    return pickerButton
    }()

  lazy var borderPickerButton: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.clear
    view.layer.borderColor = UIColor.white.cgColor
    view.layer.borderWidth = ButtonPicker.Dimensions.borderWidth
    view.layer.cornerRadius = ButtonPicker.Dimensions.buttonBorderSize / 2

    return view
    }()

  open lazy var doneButton: UIButton = { [unowned self] in
    let button = UIButton()
    button.setTitle(self.configuration.cancelButtonTitle, for: UIControl.State())
    button.titleLabel?.font = self.configuration.doneButton
    button.addTarget(self, action: #selector(doneButtonDidPress(_:)), for: .touchUpInside)

    return button
    }()

  lazy var stackView = ImageStackView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))

  lazy var topSeparator: UIView = { [unowned self] in
    let view = UIView()
    view.backgroundColor = self.configuration.backgroundColor

    return view
    }()

  lazy var tapGestureRecognizer: UITapGestureRecognizer = { [unowned self] in
    let gesture = UITapGestureRecognizer()
    gesture.addTarget(self, action: #selector(handleTapGestureRecognizer(_:)))

    return gesture
    }()

  weak var delegate: BottomContainerViewDelegate?
  var pastCount = 0

  // MARK: Initializers

  public init(configuration: ImagePickerConfiguration? = nil) {
    if let configuration = configuration {
      self.configuration = configuration
    }
    super.init(frame: .zero)
    configure()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure() {
    [borderPickerButton, pickerButton, doneButton, stackView, topSeparator].forEach {
      addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }

    backgroundColor = configuration.backgroundColor
    stackView.accessibilityLabel = "Image stack"
    stackView.addGestureRecognizer(tapGestureRecognizer)

    setupConstraints()
    if configuration.galleryOnly {
      borderPickerButton.isHidden = true
      pickerButton.isHidden = true
    }
    if !configuration.allowMultiplePhotoSelection {
      stackView.isHidden = true
    }
  }

  // MARK: - Action methods

  @objc func doneButtonDidPress(_ button: UIButton) {
    if button.currentTitle == configuration.cancelButtonTitle {
      delegate?.cancelButtonDidPress()
    } else {
      delegate?.doneButtonDidPress()
    }
  }

  @objc func handleTapGestureRecognizer(_ recognizer: UITapGestureRecognizer) {
    delegate?.imageStackViewDidPress()
  }

  fileprivate func animateImageView(_ imageView: UIImageView) {
    imageView.transform = CGAffineTransform(scaleX: 0, y: 0)

    UIView.animate(withDuration: 0.3, animations: {
      imageView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
      }, completion: { _ in
        UIView.animate(withDuration: 0.2, animations: {
          imageView.transform = CGAffineTransform.identity
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
