import UIKit

protocol ButtonPickerDelegate {

  func buttonDidPress()
}

class ButtonPicker: UIButton {

  struct Dimensions {
    static let borderWidth: CGFloat = 2
    static let buttonSize: CGFloat = 72
    static let buttonBorderSize: CGFloat = 82
  }

  lazy var numberLabel: UILabel = {
    let label = UILabel()
    label.text = ""

    return label
    }()

  lazy var border: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.clearColor()
    view.layer.borderColor = UIColor.whiteColor().CGColor
    view.layer.borderWidth = Dimensions.borderWidth
    view.layer.cornerRadius = Dimensions.buttonBorderSize / 2

    return view
    }()

  internal var photoNumber: Int = 0 {
    didSet {
      numberLabel.text = "\(photoNumber)"
    }
  }

  internal var numberFont: UIFont = UIFont(name: "Helvetica-Bold", size: 19)! {
    didSet {
      numberLabel.font = numberFont
      numberLabel.sizeToFit()
    }
  }

  var delegate: ButtonPickerDelegate?

  // MARK: - Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)

    setupButton()
    setupConstraints()
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  func setupButton() {
    backgroundColor = UIColor.whiteColor()
    frame = superview!.frame
    addTarget(self, action: "pickerButtonDidPress:", forControlEvents: .TouchUpInside)
  }

  // MARK: - Layout

  func setupConstraints() {
    let attributes: [NSLayoutAttribute] = [.CenterX, .CenterY]

    attributes.map {
      self.addConstraint(NSLayoutConstraint(item: self.numberLabel, attribute: $0,
        relatedBy: .Equal, toItem: self, attribute: $0,
        multiplier: 1, constant: 0))
    }

    attributes.map {
      self.addConstraint(NSLayoutConstraint(item: self.border, attribute: $0,
        relatedBy: .Equal, toItem: self, attribute: $0,
        multiplier: 1, constant: 0))
    }
  }

  // MARK: - Actions

  func pickerButtonDidPress(button: UIButton) {
    delegate?.buttonDidPress()
  }
}
