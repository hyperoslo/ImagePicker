import UIKit

protocol ButtonPickerDelegate: class {

  func buttonDidPress()
}

class ButtonPicker: UIButton {

  struct Dimensions {
    static let borderWidth: CGFloat = 2
    static let buttonSize: CGFloat = 58
    static let buttonBorderSize: CGFloat = 68
  }

  lazy var numberLabel: UILabel = { [unowned self] in
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = Configuration.numberLabelFont

    return label
    }()

  weak var delegate: ButtonPickerDelegate?

  // MARK: - Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(numberLabel)

    subscribe()
    setupButton()
    setupConstraints()
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  func subscribe() {
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "recalculatePhotosCount:",
      name: ImageStack.Notifications.imageDidPush,
      object: nil)

    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "recalculatePhotosCount:",
      name: ImageStack.Notifications.imageDidDrop,
      object: nil)

    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "recalculatePhotosCount:",
      name: ImageStack.Notifications.stackDidReload,
      object: nil)
  }

  required init?(coder aDecoder: NSCoder) {
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

    for attribute in attributes {
      addConstraint(NSLayoutConstraint(item: numberLabel, attribute: attribute,
        relatedBy: .Equal, toItem: self, attribute: attribute,
        multiplier: 1, constant: 0))
    }
  }

  // MARK: - Actions

  func recalculatePhotosCount(notification: NSNotification) {
    guard let sender = notification.object as? ImageStack else { return }
    numberLabel.text = sender.assets.isEmpty ? "" : String(sender.assets.count)
  }

  func pickerButtonDidPress(button: UIButton) {
    backgroundColor = .whiteColor()
    numberLabel.textColor = .blackColor()
    numberLabel.sizeToFit()
    delegate?.buttonDidPress()
  }

  func pickerButtonDidHighlight(button: UIButton) {
    numberLabel.textColor = .whiteColor()
    backgroundColor = UIColor(red:0.3, green:0.3, blue:0.3, alpha:1)
  }
}
