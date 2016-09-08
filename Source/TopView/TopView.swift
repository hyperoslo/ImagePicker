import UIKit

protocol TopViewDelegate: class {

	func flashButtonDidPress(title: String)
	func rotateDeviceDidPress()
}

class TopView: UIView {

	struct Dimensions {
		static let leftOffset: CGFloat = 11
		static let rightOffset: CGFloat = 7
		static let height: CGFloat = 34
	}

	var currentFlashIndex = 0
	let flashButtonTitles = ["AUTO", "ON", "OFF"]

	lazy var flashButton: UIButton = { [unowned self] in
		$0.setImage(AssetManager.getImage("AUTO"), forState: .Normal)
		$0.setTitle("AUTO", forState: .Normal)
		$0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
		$0.setTitleColor(.whiteColor(), forState: .Normal)
		$0.setTitleColor(.whiteColor(), forState: .Highlighted)
		$0.titleLabel?.font = Configuration.flashButton
		$0.addTarget(self, action: #selector(flashButtonDidPress(_:)), forControlEvents: .TouchUpInside)
		$0.contentHorizontalAlignment = .Left

		return $0
	}(UIButton())

	lazy var rotateCamera: UIButton = { [unowned self] in
		$0.setImage(AssetManager.getImage("cameraIcon"), forState: .Normal)
		$0.addTarget(self, action: #selector(rotateCameraButtonDidPress(_:)), forControlEvents: .TouchUpInside)
		$0.imageView?.contentMode = .Center

		return $0
	}(UIButton())

	weak var delegate: TopViewDelegate?

	// MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)

		var buttons: [UIButton] = [flashButton]

		if Configuration.canRotateCamera {
			buttons.append(rotateCamera)
		}

		for button in buttons {
			button.layer.shadowColor = UIColor.blackColor().CGColor
			button.layer.shadowOpacity = 0.5
			button.layer.shadowOffset = CGSize(width: 0, height: 1)
			button.layer.shadowRadius = 1
			button.translatesAutoresizingMaskIntoConstraints = false
			addSubview(button)
		}

		setupConstraints()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Action methods

	func flashButtonDidPress(button: UIButton) {
		currentFlashIndex += 1
		currentFlashIndex = currentFlashIndex % flashButtonTitles.count

		switch currentFlashIndex {
		case 1:
			button.setTitleColor(UIColor(red: 0.98, green: 0.98, blue: 0.45, alpha: 1), forState: .Normal)
			button.setTitleColor(UIColor(red: 0.52, green: 0.52, blue: 0.24, alpha: 1), forState: .Highlighted)
		default:
			button.setTitleColor(.whiteColor(), forState: .Normal)
			button.setTitleColor(.whiteColor(), forState: .Highlighted)
		}

		let newTitle = flashButtonTitles[currentFlashIndex]

		button.setImage(AssetManager.getImage(newTitle), forState: .Normal)
		button.setTitle(newTitle, forState: .Normal)

		delegate?.flashButtonDidPress(newTitle)
	}

	func rotateCameraButtonDidPress(button: UIButton) {
		delegate?.rotateDeviceDidPress()
	}
}
