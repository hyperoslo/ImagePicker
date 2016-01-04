import UIKit

public protocol ImagePickerDelegate: class {

  func wrapperDidPress(images: [UIImage])
  func doneButtonDidPress(images: [UIImage])
  func cancelButtonDidPress()
}

public class ImagePickerController: UIViewController {

  struct Dimensions {
    static let bottomContainerHeight: CGFloat = 101
  }

  struct GestureConstants {
    static let maximumHeight: CGFloat = 200
    static let minimumHeight: CGFloat = 125
    static let velocity: CGFloat = 100
  }

  public lazy var galleryView: ImageGalleryView = { [unowned self] in
    let galleryView = ImageGalleryView()
    galleryView.delegate = self
    galleryView.selectedStack = self.stack
    galleryView.collectionView.layer.anchorPoint = CGPoint(x: 0, y: 0)
    galleryView.imageLimit = self.imageLimit

    return galleryView
    }()

  public lazy var bottomContainer: BottomContainerView = { [unowned self] in
    let view = BottomContainerView()
    view.backgroundColor = UIColor(red:0.09, green:0.11, blue:0.13, alpha:1)
    view.delegate = self

    return view
    }()

  lazy var topView: TopView = { [unowned self] in
    let view = TopView()
    view.backgroundColor = .clearColor()
    view.delegate = self

    return view
    }()

  lazy var cameraController: CameraView = { [unowned self] in
    let controller = CameraView()
    controller.delegate = self

    return controller
    }()

  lazy var panGestureRecognizer: UIPanGestureRecognizer = { [unowned self] in
    let gesture = UIPanGestureRecognizer()
    gesture.addTarget(self, action: "panGestureRecognizerHandler:")

    return gesture
    }()

  public weak var delegate: ImagePickerDelegate?
  public var stack = ImageStack()
  public var imageLimit = 0
  let totalSize = UIScreen.mainScreen().bounds.size
  var initialFrame: CGRect?
  var initialContentOffset: CGPoint?
  var numberOfCells: Int?
  var statusBarHidden = true

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

    view.backgroundColor = .whiteColor()
    view.backgroundColor = Configuration.mainColor
    cameraController.view.addGestureRecognizer(panGestureRecognizer)

    subscribe()
    setupConstraints()
  }

  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    statusBarHidden = UIApplication.sharedApplication().statusBarHidden
    UIApplication.sharedApplication().statusBarHidden = true
  }

  public override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    let galleryHeight: CGFloat = UIScreen.mainScreen().nativeBounds.height == 960
      ? ImageGalleryView.Dimensions.galleryBarHeight : GestureConstants.minimumHeight

    galleryView.frame = CGRectMake(0, totalSize.height - bottomContainer.frame.height - galleryHeight,
      totalSize.width, galleryHeight)
    galleryView.updateFrames()
    galleryView.checkStatus()

    initialFrame = galleryView.frame
    initialContentOffset = galleryView.collectionView.contentOffset
  }

  public override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    UIApplication.sharedApplication().statusBarHidden = statusBarHidden
  }

  // MARK: - Notifications

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  func subscribe() {
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "adjustButtonTitle:",
      name: ImageStack.Notifications.imageDidPush,
      object: nil)

    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "adjustButtonTitle:",
      name: ImageStack.Notifications.imageDidDrop,
      object: nil)

    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "adjustButtonTitle:",
      name: ImageStack.Notifications.stackDidReload,
      object: nil)
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
      self.galleryView.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right:  value)
    })
  }

  func updateGalleryViewFrames(constant: CGFloat) {
    galleryView.frame.origin.y = totalSize.height - bottomContainer.frame.height - constant
    galleryView.frame.size.height = constant
  }

  func updateCollectionViewFrames(maximum: Bool) {
    let constant = maximum ? GestureConstants.maximumHeight : GestureConstants.minimumHeight
    galleryView.collectionView.frame.size.height = constant - galleryView.topSeparator.frame.height
    galleryView.collectionSize = CGSize(width: galleryView.collectionView.frame.height, height: galleryView.collectionView.frame.height)

    galleryView.updateNoImagesLabel()
  }

  func enableGestures(enabled: Bool) {
    galleryView.alpha = enabled ? 1 : 0
    bottomContainer.pickerButton.enabled = enabled
    bottomContainer.tapGestureRecognizer.enabled = enabled
    topView.flashButton.enabled = enabled
    topView.rotateCamera.enabled = enabled
  }
}

// MARK: - Action methods

extension ImagePickerController: BottomContainerViewDelegate {

  func pickerButtonDidPress() {
    guard imageLimit == 0 || imageLimit > galleryView.selectedStack.assets.count else { return }
    
    bottomContainer.pickerButton.enabled = false
    bottomContainer.stackView.startLoader()
    collapseGalleryView { [unowned self] in
      self.cameraController.takePicture()
    }
  }

  func doneButtonDidPress() {
    let images = ImagePicker.resolveAssets(stack.assets)
    delegate?.doneButtonDidPress(images)
  }

  func cancelButtonDidPress() {
    dismissViewControllerAnimated(true, completion: nil)
    delegate?.cancelButtonDidPress()
  }

  func imageStackViewDidPress() {
    let images = ImagePicker.resolveAssets(stack.assets)
    delegate?.wrapperDidPress(images)
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

  func hideViews() {
    enableGestures(false)
  }

  func permissionGranted() {
    galleryView.fetchPhotos()
    galleryView.canFetchImages = false
    cameraController.initializeCamera()
    enableGestures(true)
  }

  func presentViewController(controller: UIAlertController) {
    presentViewController(controller, animated: true, completion: nil)
  }

  func dismissViewController(controller: UIAlertController) {
    dismissViewControllerAnimated(true, completion: nil)
  }

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
      galleryView.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right:  value)

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
