import UIKit

protocol BottomContainerViewDelegate: class {

	func pickerButtonDidPress()
	func doneButtonDidPress()
	func cancelButtonDidPress()
	func imageStackViewDidPress()
}

public class BottomContainerView: UIView {

	struct Dimensions {
		static let height: CGFloat = 101
	}

	lazy var pickerButton: ButtonPicker = { [unowned self] in
		$0.setTitleColor(.whiteColor(), forState: .Normal)
		$0.delegate = self

		return $0
	}(ButtonPicker())

	lazy var borderPickerButton: UIView = {
		$0.backgroundColor = .clearColor()
		$0.layer.borderColor = UIColor.whiteColor().CGColor
		$0.layer.borderWidth = ButtonPicker.Dimensions.borderWidth
		$0.layer.cornerRadius = ButtonPicker.Dimensions.buttonBorderSize / 2

		return $0
	}(UIView())

	public lazy var doneButton: UIButton = { [unowned self] in
		$0.setTitle(Configuration.cancelButtonTitle, forState: .Normal)
		$0.titleLabel?.font = Configuration.doneButton
		$0.addTarget(self, action: #selector(doneButtonDidPress(_:)), forControlEvents: .TouchUpInside)

		return $0
	}(UIButton())

	lazy var stackView = ImageStackView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))

	lazy var topSeparator: UIView = { [unowned self] in
		$0.backgroundColor = Configuration.backgroundColor

		return $0
	}(UIView())

	lazy var tapGestureRecognizer: UITapGestureRecognizer = { [unowned self] in
		$0.addTarget(self, action: #selector(handleTapGestureRecognizer(_:)))

		return $0
	}(UITapGestureRecognizer())

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

	func doneButtonDidPress(button: UIButton) {
		if button.currentTitle == Configuration.cancelButtonTitle {
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
		}) { _ in
			UIView.animateWithDuration(0.2) { _ in
				imageView.transform = CGAffineTransformIdentity
			}
		}
	}
}

// MARK: - ButtonPickerDelegate methods

extension BottomContainerView: ButtonPickerDelegate {

	func buttonDidPress() {
		delegate?.pickerButtonDidPress()
	}
}
