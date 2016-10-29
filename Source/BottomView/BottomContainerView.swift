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

  lazy var pickerButton: ButtonPicker = { [unowned self] in
    let pickerButton = ButtonPicker()
    pickerButton.setTitleColor(UIColor.white, for: UIControlState())
    pickerButton.delegate = self

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
    button.setTitle(Configuration.cancelButtonTitle, for: UIControlState())
    button.titleLabel?.font = Configuration.doneButton
    button.addTarget(self, action: #selector(doneButtonDidPress(_:)), for: .touchUpInside)

    return button
    }()

  lazy var stackView = ImageStackView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))

  lazy var topSeparator: UIView = { [unowned self] in
    let view = UIView()
    view.backgroundColor = Configuration.backgroundColor

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

  public override init(frame: CGRect) {
    super.init(frame: frame)

    [borderPickerButton, pickerButton, doneButton, stackView, topSeparator].forEach {
      addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }

    backgroundColor = Configuration.backgroundColor
    stackView.accessibilityLabel = "Image stack"
    stackView.addGestureRecognizer(tapGestureRecognizer)

    setupConstraints()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Action methods

  func doneButtonDidPress(_ button: UIButton) {
    if button.currentTitle == Configuration.cancelButtonTitle {
      delegate?.cancelButtonDidPress()
    } else {
      delegate?.doneButtonDidPress()
    }
  }

  func handleTapGestureRecognizer(_ recognizer: UITapGestureRecognizer) {
    delegate?.imageStackViewDidPress()
  }

  fileprivate func animateImageView(_ imageView: UIImageView) {
    imageView.transform = CGAffineTransform(scaleX: 0, y: 0)

    UIView.animate(withDuration: 0.3, animations: {
      imageView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
      }, completion: { _ in
        UIView.animate(withDuration: 0.2, animations: { _ in
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
