import UIKit
import AVFoundation
import PhotosUI

protocol CameraViewDelegate: class {

	func setFlashButtonHidden(hidden: Bool)
	func imageToLibrary()
	func cameraNotAvailable()
}

class CameraView: UIViewController {

	lazy var blurView: UIVisualEffectView = { [unowned self] in
		let effect = UIBlurEffect(style: .Dark)
		let blurView = UIVisualEffectView(effect: effect)

		return blurView
	}()

	lazy var focusImageView: UIImageView = { [unowned self] in
		$0.image = AssetManager.getImage("focusIcon")
		$0.backgroundColor = .clearColor()
		$0.frame = CGRect(x: 0, y: 0, width: 110, height: 110)
		$0.alpha = 0

		return $0
	}(UIImageView())

	lazy var capturedImageView: UIView = { [unowned self] in
		$0.backgroundColor = .blackColor()
		$0.alpha = 0

		return $0
	}(UIView())

	lazy var containerView: UIView = {
		$0.alpha = 0

		return $0
	}(UIView())

	lazy var noCameraLabel: UILabel = { [unowned self] in
		$0.font = Configuration.noCameraFont
		$0.textColor = Configuration.noCameraColor
		$0.text = Configuration.noCameraTitle
		$0.sizeToFit()

		return $0
	}(UILabel())

	lazy var noCameraButton: UIButton = { [unowned self] in
		let title = NSAttributedString(string: Configuration.settingsTitle,
			attributes: [
				NSFontAttributeName: Configuration.settingsFont,
				NSForegroundColorAttributeName: Configuration.settingsColor,
		])

		$0.setAttributedTitle(title, forState: .Normal)
		$0.contentEdgeInsets = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
		$0.sizeToFit()
		$0.layer.borderColor = Configuration.settingsColor.CGColor
		$0.layer.borderWidth = 1
		$0.layer.cornerRadius = 4
		$0.addTarget(self, action: #selector(settingsButtonDidTap), forControlEvents: .TouchUpInside)

		return $0
	}(UIButton(type: .System))

	lazy var tapGestureRecognizer: UITapGestureRecognizer = { [unowned self] in
		$0.addTarget(self, action: #selector(tapGestureRecognizerHandler(_:)))

		return $0
	}(UITapGestureRecognizer())

	let cameraMan = CameraMan()

	var previewLayer: AVCaptureVideoPreviewLayer?
	weak var delegate: CameraViewDelegate?
	var animationTimer: NSTimer?
	var locationManager: LocationManager?

	override func viewDidLoad() {
		super.viewDidLoad()

		if Configuration.recordLocation {
			locationManager = LocationManager()
		}

		view.backgroundColor = Configuration.mainColor
		view.addSubview(containerView)
		containerView.addSubview(blurView)

		[focusImageView, capturedImageView].forEach {
			view.addSubview($0)
		}

		view.addGestureRecognizer(tapGestureRecognizer)

		cameraMan.delegate = self
		cameraMan.setup()
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		previewLayer?.connection.videoOrientation = .Portrait
		locationManager?.startUpdatingLocation()
	}

	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		locationManager?.stopUpdatingLocation()
	}

	func setupPreviewLayer() {
		guard let layer = AVCaptureVideoPreviewLayer(session: cameraMan.session) else { return }

		layer.backgroundColor = Configuration.mainColor.CGColor
		layer.autoreverses = true
		layer.videoGravity = AVLayerVideoGravityResizeAspectFill

		view.layer.insertSublayer(layer, atIndex: 0)
		layer.frame = view.layer.frame
		view.clipsToBounds = true

		previewLayer = layer
	}

	// MARK: - Layout

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		let centerX = view.bounds.width / 2

		noCameraLabel.center = CGPoint(x: centerX,
			y: view.bounds.height / 2 - 80)

		noCameraButton.center = CGPoint(x: centerX,
			y: noCameraLabel.frame.maxY + 20)

		blurView.frame = view.bounds
		containerView.frame = view.bounds
		capturedImageView.frame = view.bounds
	}

	// MARK: - Actions

	func settingsButtonDidTap() {
		dispatch_async(dispatch_get_main_queue()) {
			if let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString) {
				UIApplication.sharedApplication().openURL(settingsURL)
			}
		}
	}

	// MARK: - Camera actions

	func rotateCamera() {
		UIView.animateWithDuration(0.3, animations: { _ in
			self.containerView.alpha = 1
			}, completion: { _ in
			self.cameraMan.switchCamera {
				UIView.animateWithDuration(0.7) {
					self.containerView.alpha = 0
				}
			}
		})
	}

	func flashCamera(title: String) {
		let mapping: [String: AVCaptureFlashMode] = [
			"ON": .On,
			"OFF": .Off
		]

		cameraMan.flash(mapping[title] ?? .Auto)
	}

	func takePicture(completion: () -> ()) {
		guard let previewLayer = previewLayer else { return }

		UIView.animateWithDuration(0.1, animations: {
			self.capturedImageView.alpha = 1
			}, completion: { _ in
			UIView.animateWithDuration(0.1) {
				self.capturedImageView.alpha = 0
			}
		})

		cameraMan.takePhoto(previewLayer, location: locationManager?.latestLocation) {
			completion()
			self.delegate?.imageToLibrary()
		}
	}

	// MARK: - Timer methods

	func timerDidFire() {
		UIView.animateWithDuration(0.3, animations: { [unowned self] in
			self.focusImageView.alpha = 0
			}, completion: { _ in
			self.focusImageView.transform = CGAffineTransformIdentity
		})
	}

	// MARK: - Camera methods

	func focusTo(point: CGPoint) {
		let convertedPoint = CGPoint(x: point.x / UIScreen.mainScreen().bounds.width,
			y: point.y / UIScreen.mainScreen().bounds.height)

		cameraMan.focus(convertedPoint)

		focusImageView.center = point
		UIView.animateWithDuration(0.5, animations: { _ in
			self.focusImageView.alpha = 1
			self.focusImageView.transform = CGAffineTransformMakeScale(0.6, 0.6)
			}, completion: { _ in
			self.animationTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self,
				selector: #selector(CameraView.timerDidFire), userInfo: nil, repeats: false)
		})
	}

	// MARK: - Tap

	func tapGestureRecognizerHandler(gesture: UITapGestureRecognizer) {
		let touch = gesture.locationInView(view)

		focusImageView.transform = CGAffineTransformIdentity
		animationTimer?.invalidate()
		focusTo(touch)
	}

	// MARK: - Private helpers

	func showNoCamera(show: Bool) {
		[noCameraButton, noCameraLabel].forEach {
			show ? view.addSubview($0) : $0.removeFromSuperview()
		}
	}

}

extension CameraView: CameraManDelegate {

	func cameraManNotAvailable(cameraMan: CameraMan) {
		showNoCamera(true)
		focusImageView.hidden = true
		delegate?.cameraNotAvailable()
	}

	func cameraMan(cameraMan: CameraMan, didChangeInput input: AVCaptureDeviceInput) {
		delegate?.setFlashButtonHidden(!input.device.hasFlash)
	}

	func cameraManDidStart(cameraMan: CameraMan) {
		setupPreviewLayer()
	}

}
