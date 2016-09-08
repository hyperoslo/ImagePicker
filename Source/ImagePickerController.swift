import UIKit
import MediaPlayer
import Photos

@objc public protocol ImagePickerDelegate: class {

	func wrapperDidPress(imagePicker: ImagePickerController, images: [UIImage])
	func doneButtonDidPress(imagePicker: ImagePickerController, images: [UIImage])
	func cancelButtonDidPress(imagePicker: ImagePickerController)
}

public class ImagePickerController: UIViewController {

	enum GestureConstants {
		static let maximumHeight: CGFloat = 200
		static let minimumHeight: CGFloat = 125
		static let velocity: CGFloat = 100
	}

	public lazy var galleryView: ImageGalleryView = { [unowned self] in
		$0.delegate = self
		$0.selectedStack = self.stack
		$0.collectionView.layer.anchorPoint = CGPoint(x: 0, y: 0)
		$0.imageLimit = self.imageLimit

		return $0
	}(ImageGalleryView())

	public lazy var bottomContainer: BottomContainerView = { [unowned self] in
		$0.backgroundColor = UIColor(red: 0.09, green: 0.11, blue: 0.13, alpha: 1)
		$0.delegate = self

		return $0
	}(BottomContainerView())

	lazy var topView: TopView = { [unowned self] in
		$0.backgroundColor = .clearColor()
		$0.delegate = self

		return $0
	}(TopView())

	lazy var cameraController: CameraView = { [unowned self] in
		$0.delegate = self

		return $0
	}(CameraView())

	lazy var panGestureRecognizer: UIPanGestureRecognizer = { [unowned self] in
		$0.addTarget(self, action: #selector(panGestureRecognizerHandler(_:)))

		return $0
	}(UIPanGestureRecognizer())

	lazy var volumeView: MPVolumeView = { [unowned self] in
		$0.frame = CGRect(x: 0, y: 0, width: 1, height: 1)

		return $0
	}(MPVolumeView())

	var volume = AVAudioSession.sharedInstance().outputVolume

	public weak var delegate: ImagePickerDelegate?
	public var stack = ImageStack()
	public var imageLimit = 0
	public var preferredImageSize: CGSize?
	var totalSize: CGSize { return UIScreen.mainScreen().bounds.size }
	var initialFrame: CGRect?
	var initialContentOffset: CGPoint?
	var numberOfCells: Int?
	var statusBarHidden = true

	private var isTakingPicture = false
	public var doneButtonTitle: String? {
		didSet {
			if let doneButtonTitle = doneButtonTitle {
				bottomContainer.doneButton.setTitle(doneButtonTitle, forState: .Normal)
			}
		}
	}

	// MARK: - View lifecycle

	public override func viewDidLoad() {
		super.viewDidLoad()

		for subview in [cameraController.view, galleryView, bottomContainer, topView] {
			view.addSubview(subview)
			subview.translatesAutoresizingMaskIntoConstraints = false
		}

		view.addSubview(volumeView)
		view.sendSubviewToBack(volumeView)

		view.backgroundColor = .whiteColor()
		view.backgroundColor = Configuration.mainColor

		cameraController.view.addGestureRecognizer(panGestureRecognizer)

		subscribe()
		setupConstraints()
	}

	public override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		_ = try? AVAudioSession.sharedInstance().setActive(true)

		statusBarHidden = UIApplication.sharedApplication().statusBarHidden
		UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
	}

	public override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		let galleryHeight: CGFloat = UIScreen.mainScreen().nativeBounds.height == 960
			? ImageGalleryView.Dimensions.galleryBarHeight : GestureConstants.minimumHeight

		galleryView.collectionView.transform = CGAffineTransformIdentity
		galleryView.collectionView.contentInset = UIEdgeInsetsZero

		galleryView.frame = CGRect(x: 0,
			y: totalSize.height - bottomContainer.frame.height - galleryHeight,
			width: totalSize.width,
			height: galleryHeight)
		galleryView.updateFrames()
		checkStatus()

		initialFrame = galleryView.frame
		initialContentOffset = galleryView.collectionView.contentOffset
	}

	public override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		UIApplication.sharedApplication().setStatusBarHidden(statusBarHidden, withAnimation: .Fade)
	}

	public func resetAssets() {
		self.stack.resetAssets([])
	}

	func checkStatus() {
		let currentStatus = PHPhotoLibrary.authorizationStatus()
		guard currentStatus != .Authorized else { return }

		if currentStatus == .NotDetermined { hideViews() }

		PHPhotoLibrary.requestAuthorization { (authorizationStatus) -> Void in
			dispatch_async(dispatch_get_main_queue()) {
				if authorizationStatus == .Denied {
					self.presentAskPermissionAlert()
				} else if authorizationStatus == .Authorized {
					self.permissionGranted()
				}
			}
		}
	}

	func presentAskPermissionAlert() {
		let alertController = UIAlertController(title: Configuration.requestPermissionTitle, message: Configuration.requestPermissionMessage, preferredStyle: .Alert)

		let alertAction = UIAlertAction(title: Configuration.OKButtonTitle, style: .Default) { _ in
			if let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString) {
				UIApplication.sharedApplication().openURL(settingsURL)
			}
		}

		let cancelAction = UIAlertAction(title: Configuration.cancelButtonTitle, style: .Cancel) { _ in
			self.dismissViewControllerAnimated(true, completion: nil)
		}

		alertController.addAction(alertAction)
		alertController.addAction(cancelAction)

		presentViewController(alertController, animated: true, completion: nil)
	}

	func hideViews() {
		enableGestures(false)
	}

	func permissionGranted() {
		galleryView.fetchPhotos()
		galleryView.canFetchImages = false
		enableGestures(true)
	}

	// MARK: - Notifications

	deinit {
		_ = try? AVAudioSession.sharedInstance().setActive(false)
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}

	func subscribe() {
		NSNotificationCenter.defaultCenter().addObserver(self,
			selector: #selector(adjustButtonTitle(_:)),
			name: ImageStack.Notifications.imageDidPush,
			object: nil)

		NSNotificationCenter.defaultCenter().addObserver(self,
			selector: #selector(adjustButtonTitle(_:)),
			name: ImageStack.Notifications.imageDidDrop,
			object: nil)

		NSNotificationCenter.defaultCenter().addObserver(self,
			selector: #selector(didReloadAssets(_:)),
			name: ImageStack.Notifications.stackDidReload,
			object: nil)

		NSNotificationCenter.defaultCenter().addObserver(self,
			selector: #selector(volumeChanged(_:)),
			name: "AVSystemController_SystemVolumeDidChangeNotification",
			object: nil)

		NSNotificationCenter.defaultCenter().addObserver(self,
			selector: #selector(handleRotation(_:)),
			name: UIDeviceOrientationDidChangeNotification,
			object: nil)
	}

	func didReloadAssets(notification: NSNotification) {
		adjustButtonTitle(notification)
		galleryView.collectionView.reloadData()
		galleryView.collectionView.setContentOffset(CGPoint.zero, animated: false)
	}

	func volumeChanged(notification: NSNotification) {
		guard let slider = volumeView.subviews.filter({ $0 is UISlider }).first as? UISlider,
			userInfo = notification.userInfo,
			changeReason = userInfo["AVSystemController_AudioVolumeChangeReasonNotificationParameter"] as? String
		where changeReason == "ExplicitVolumeChange" else { return }

		slider.setValue(volume, animated: false)
		takePicture()
	}

	func adjustButtonTitle(notification: NSNotification) {
		guard let sender = notification.object as? ImageStack else { return }

		let title = !sender.assets.isEmpty ?
		Configuration.doneButtonTitle : Configuration.cancelButtonTitle
		bottomContainer.doneButton.setTitle(title, forState: .Normal)
	}

	// MARK: - Helpers

	public override func prefersStatusBarHidden() -> Bool {
		return true
	}

	public func collapseGalleryView(completion: (() -> Void)?) {
		galleryView.collectionViewLayout.invalidateLayout()
		UIView.animateWithDuration(0.3, animations: {
			self.updateGalleryViewFrames(self.galleryView.topSeparator.frame.height)
			self.galleryView.collectionView.transform = CGAffineTransformIdentity
			self.galleryView.collectionView.contentInset = UIEdgeInsetsZero
		}) { _ in
			completion?()
		}
	}

	public func showGalleryView() {
		galleryView.collectionViewLayout.invalidateLayout()
		UIView.animateWithDuration(0.3, animations: {
			self.updateGalleryViewFrames(GestureConstants.minimumHeight)
			self.galleryView.collectionView.transform = CGAffineTransformIdentity
			self.galleryView.collectionView.contentInset = UIEdgeInsetsZero
		})
	}

	public func expandGalleryView() {
		galleryView.collectionViewLayout.invalidateLayout()

		UIView.animateWithDuration(0.3, animations: {
			self.updateGalleryViewFrames(GestureConstants.maximumHeight)

			let scale = (GestureConstants.maximumHeight - ImageGalleryView.Dimensions.galleryBarHeight) / (GestureConstants.minimumHeight - ImageGalleryView.Dimensions.galleryBarHeight)
			self.galleryView.collectionView.transform = CGAffineTransformMakeScale(scale, scale)

			let value = self.view.frame.width * (scale - 1) / scale
			self.galleryView.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: value)
		})
	}

	func updateGalleryViewFrames(constant: CGFloat) {
		galleryView.frame.origin.y = totalSize.height - bottomContainer.frame.height - constant
		galleryView.frame.size.height = constant
	}

	func enableGestures(enabled: Bool) {
		galleryView.alpha = enabled ? 1 : 0
		bottomContainer.pickerButton.enabled = enabled
		bottomContainer.tapGestureRecognizer.enabled = enabled
		topView.flashButton.enabled = enabled
		topView.rotateCamera.enabled = Configuration.canRotateCamera
	}

	private func isBelowImageLimit() -> Bool {
		return (imageLimit == 0 || imageLimit > galleryView.selectedStack.assets.count)
	}

	private func takePicture() {
		guard isBelowImageLimit() && !isTakingPicture else { return }
		isTakingPicture = true
		bottomContainer.pickerButton.enabled = false
		bottomContainer.stackView.startLoader()
		let action: Void -> Void = { [unowned self] in
			self.cameraController.takePicture { self.isTakingPicture = false }
		}

		if Configuration.collapseCollectionViewWhileShot {
			collapseGalleryView(action)
		} else {
			action()
		}
	}
}

// MARK: - Action methods

extension ImagePickerController: BottomContainerViewDelegate {

	func pickerButtonDidPress() {
		takePicture()
	}

	func doneButtonDidPress() {
		var images: [UIImage]
		if let preferredImageSize = preferredImageSize {
			images = AssetManager.resolveAssets(stack.assets, size: preferredImageSize)
		} else {
			images = AssetManager.resolveAssets(stack.assets)
		}

		delegate?.doneButtonDidPress(self, images: images)
	}

	func cancelButtonDidPress() {
		dismissViewControllerAnimated(true, completion: nil)
		delegate?.cancelButtonDidPress(self)
	}

	func imageStackViewDidPress() {
		var images: [UIImage]
		if let preferredImageSize = preferredImageSize {
			images = AssetManager.resolveAssets(stack.assets, size: preferredImageSize)
		} else {
			images = AssetManager.resolveAssets(stack.assets)
		}

		delegate?.wrapperDidPress(self, images: images)
	}
}

extension ImagePickerController: CameraViewDelegate {

	func setFlashButtonHidden(hidden: Bool) {
		topView.flashButton.hidden = hidden
	}

	func imageToLibrary() {
		guard let collectionSize = galleryView.collectionSize else { return }

		galleryView.fetchPhotos() {
			guard let asset = self.galleryView.assets.first else { return }
			self.stack.pushAsset(asset)
		}
		galleryView.shouldTransform = true
		bottomContainer.pickerButton.enabled = true

		UIView.animateWithDuration(0.3, animations: {
			self.galleryView.collectionView.transform = CGAffineTransformMakeTranslation(collectionSize.width, 0)
		}) { _ in
			self.galleryView.collectionView.transform = CGAffineTransformIdentity
		}
	}

	func cameraNotAvailable() {
		topView.flashButton.hidden = true
		topView.rotateCamera.hidden = true
		bottomContainer.pickerButton.enabled = false
	}

	// MARK: - Rotation

	public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
		return .Portrait
	}

	public func handleRotation(note: NSNotification) {
		let rotate = Helper.rotationTransform()

		UIView.animateWithDuration(0.25) {
			[self.topView.rotateCamera, self.bottomContainer.pickerButton,
				self.bottomContainer.stackView, self.bottomContainer.doneButton].forEach {
					$0.transform = rotate
			}

			self.galleryView.collectionViewLayout.invalidateLayout()

			let translate: CGAffineTransform
			if [UIDeviceOrientation.LandscapeLeft, UIDeviceOrientation.LandscapeRight]
				.contains(UIDevice.currentDevice().orientation) {
					translate = CGAffineTransformMakeTranslation(-20, 15)
			} else {
					translate = CGAffineTransformIdentity
			}

			self.topView.flashButton.transform = CGAffineTransformConcat(rotate, translate)
		}
	}
}

// MARK: - TopView delegate methods

extension ImagePickerController: TopViewDelegate {

	func flashButtonDidPress(title: String) {
		cameraController.flashCamera(title)
	}

	func rotateDeviceDidPress() {
		cameraController.rotateCamera()
	}
}

// MARK: - Pan gesture handler

extension ImagePickerController: ImageGalleryPanGestureDelegate {

	func panGestureDidStart() {
		guard let collectionSize = galleryView.collectionSize else { return }

		initialFrame = galleryView.frame
		initialContentOffset = galleryView.collectionView.contentOffset
		if let contentOffset = initialContentOffset { numberOfCells = Int(contentOffset.x / collectionSize.width) }
	}

	func panGestureRecognizerHandler(gesture: UIPanGestureRecognizer) {
		let translation = gesture.translationInView(view)
		let velocity = gesture.velocityInView(view)

		if gesture.locationInView(view).y > galleryView.frame.origin.y - 25 {
			gesture.state == .Began ? panGestureDidStart() : panGestureDidChange(translation)
		}

		if gesture.state == .Ended {
			panGestureDidEnd(translation, velocity: velocity)
		}
	}

	func panGestureDidChange(translation: CGPoint) {
		guard let initialFrame = initialFrame else { return }

		let galleryHeight = initialFrame.height - translation.y

		if galleryHeight >= GestureConstants.maximumHeight { return }

		if galleryHeight <= ImageGalleryView.Dimensions.galleryBarHeight {
			updateGalleryViewFrames(ImageGalleryView.Dimensions.galleryBarHeight)

		} else if galleryHeight >= GestureConstants.minimumHeight {

			let scale = (galleryHeight - ImageGalleryView.Dimensions.galleryBarHeight) / (GestureConstants.minimumHeight - ImageGalleryView.Dimensions.galleryBarHeight)
			galleryView.collectionView.transform = CGAffineTransformMakeScale(scale, scale)
			galleryView.frame.origin.y = initialFrame.origin.y + translation.y
			galleryView.frame.size.height = initialFrame.height - translation.y

			let value = view.frame.width * (scale - 1) / scale
			galleryView.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: value)

		} else {

			galleryView.frame.origin.y = initialFrame.origin.y + translation.y
			galleryView.frame.size.height = initialFrame.height - translation.y
		}

		galleryView.updateNoImagesLabel()
	}

	func panGestureDidEnd(translation: CGPoint, velocity: CGPoint) {
		guard let initialFrame = initialFrame else { return }

		let galleryHeight = initialFrame.height - translation.y

		if galleryView.frame.height < GestureConstants.minimumHeight && velocity.y < 0 {
			showGalleryView()
		} else if velocity.y < -GestureConstants.velocity {
			expandGalleryView()
		} else if velocity.y > GestureConstants.velocity || galleryHeight < GestureConstants.minimumHeight {
			collapseGalleryView(nil)
		}
	}
}
