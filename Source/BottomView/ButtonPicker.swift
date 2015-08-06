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

  lazy var numberLabel: UILabel = { [unowned self] in
    let label = UILabel()
    label.text = ""
    label.setTranslatesAutoresizingMaskIntoConstraints(false)
    label.font = self.configuration.numberLabelFont

    return label
    }()

  lazy var configuration: PickerConfiguration = {
    let configuration = PickerConfiguration()
    return configuration
  }()

  internal var photoNumber: Int = 0 {
    didSet {
      numberLabel.text = photoNumber == 0 ? "" : "\(photoNumber)"
    }
  }

  var delegate: ButtonPickerDelegate?

  // MARK: - Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)

    [numberLabel].map { self.addSubview($0) }

    setupButton()
    setupConstraints()
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  func setupButton() {
    backgroundColor = .whiteColor()
    layer.cornerRadius = Dimensions.buttonSize / 2
    addTarget(self, action: "pickerButtonDidPress:", forControlEvents: .TouchUpInside)
    addTarget(self, action: "pickerButtonDidHighlight:", forControlEvents: .TouchDown)
  }

  // MARK: - Layout

  func setupConstraints() {
    let attributes: [NSLayoutAttribute] = [.CenterX, .CenterY]

    attributes.map {
      self.addConstraint(NSLayoutConstraint(item: self.numberLabel, attribute: $0,
        relatedBy: .Equal, toItem: self, attribute: $0,
        multiplier: 1, constant: 0))
    }
  }

  // MARK: - Actions

  func pickerButtonDidPress(button: UIButton) {
    backgroundColor = .whiteColor()
    numberLabel.textColor = .blackColor()
    photoNumber = photoNumber + 1
    numberLabel.sizeToFit()
    delegate?.buttonDidPress()
  }

  func pickerButtonDidHighlight(button: UIButton) {
    numberLabel.textColor = .whiteColor()
    backgroundColor = UIColor(red:0.3, green:0.3, blue:0.3, alpha:1)
  }
}
