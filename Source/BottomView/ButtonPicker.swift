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

  var imagePickerConfiguration = ImagePickerConfiguration()

  lazy var numberLabel: UILabel = { [unowned self] in
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = self.imagePickerConfiguration.numberLabelFont

    return label
    }()

  weak var delegate: ButtonPickerDelegate?

  // MARK: - Initializers

  public init(configuration: ImagePickerConfiguration? = nil) {
    if let configuration = configuration {
      self.imagePickerConfiguration = configuration
    }
    super.init(frame: .zero)
    configure()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  func configure() {
    addSubview(numberLabel)

    subscribe()
    setupButton()
    setupConstraints()
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  func subscribe() {
    NotificationCenter.default.addObserver(self,
      selector: #selector(recalculatePhotosCount(_:)),
      name: NSNotification.Name(rawValue: ImageStack.Notifications.imageDidPush),
      object: nil)

    NotificationCenter.default.addObserver(self,
      selector: #selector(recalculatePhotosCount(_:)),
      name: NSNotification.Name(rawValue: ImageStack.Notifications.imageDidDrop),
      object: nil)

    NotificationCenter.default.addObserver(self,
      selector: #selector(recalculatePhotosCount(_:)),
      name: NSNotification.Name(rawValue: ImageStack.Notifications.stackDidReload),
      object: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  func setupButton() {
    backgroundColor = UIColor.white
    layer.cornerRadius = Dimensions.buttonSize / 2
    accessibilityLabel = "Take photo"
    addTarget(self, action: #selector(pickerButtonDidPress(_:)), for: .touchUpInside)
    addTarget(self, action: #selector(pickerButtonDidHighlight(_:)), for: .touchDown)
  }

  // MARK: - Actions

  @objc func recalculatePhotosCount(_ notification: Notification) {
    guard let sender = notification.object as? ImageStack else { return }
    numberLabel.text = sender.assets.isEmpty ? "" : String(sender.assets.count)
  }

  @objc func pickerButtonDidPress(_ button: UIButton) {
    backgroundColor = UIColor.white
    numberLabel.textColor = UIColor.black
    numberLabel.sizeToFit()
    delegate?.buttonDidPress()
  }

  @objc func pickerButtonDidHighlight(_ button: UIButton) {
    numberLabel.textColor = UIColor.white
    backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
  }
}
