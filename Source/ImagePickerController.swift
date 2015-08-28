import UIKit

@objc
public protocol ImagePickerDelegate: class {

  optional func wrapperDidPress(images: [UIImage])
  optional func doneButtonDidPress(images: [UIImage])
  optional func cancelButtonDidPress()
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

  public var stack = ImageStack()

  lazy public var galleryView: ImageGalleryView = { [unowned self] in
    let galleryView = ImageGalleryView()
    galleryView.delegate = self
    galleryView.selectedStack = self.stack

    return galleryView
    }()

  lazy var bottomContainer: BottomContainerView = { [unowned self] in
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

  lazy var configuration: PickerConfiguration = {
    let configuration = PickerConfiguration()
    return configuration
    }()

  lazy var cameraController: CameraView = { [unowned self] in
    let controller = CameraView()
    controller.delegate = self

    return controller
    }()

  let totalHeight = UIScreen.mainScreen().bounds.size.height
  let totalWidth = UIScreen.mainScreen().bounds.size.width
  var initialFrame: CGRect!
  var initialContentOffset: CGPoint!
  var numberOfCells: Int!
  public weak var delegate: ImagePickerDelegate?

  public var doneButtonTitle: String? {
    didSet {
      bottomContainer.doneButton.setTitle(doneButtonTitle!, forState: .Normal)
    }
  }

  // MARK: - View lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    for subview in [cameraController.view, galleryView, bottomContainer, topView] {
      view.addSubview(subview)
      subview.setTranslatesAutoresizingMaskIntoConstraints(false)
    }

    view.backgroundColor = .whiteColor()
    view.backgroundColor = self.configuration.mainColor

    subscribe()
    setupConstraints()
  }

  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    UIApplication.sharedApplication().statusBarHidden = true
  }

  public override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    let galleryHeight: CGFloat = UIScreen.mainScreen().nativeBounds.height == 960 ? 34 : 134

    galleryView.frame = CGRectMake(0, totalHeight - bottomContainer.frame.height - galleryHeight,
      totalWidth, galleryHeight)
    galleryView.updateFrames()
    galleryView.checkStatus()
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
    if let sender = notification.object as? ImageStack {
      let title = !sender.images.isEmpty ?
        configuration.doneButtonTitle : configuration.cancelButtonTitle
      bottomContainer.doneButton.setTitle(title, forState: .Normal)
    }
  }

  // MARK: - Helpers

  public override func prefersStatusBarHidden() -> Bool {
    return true
  }

  public func collapseGalleryView(completion: (() -> Void)?) {
    UIView.animateWithDuration(0.3, animations: {
      self.updateGalleryViewFrames(self.galleryView.topSeparator.frame.height)
      self.updateCollectionViewFrames(false)
      }, completion: { finished in
        completion?()
    })
  }

  public func showGalleryView() {
    UIView.animateWithDuration(0.3, animations: {
      self.updateGalleryViewFrames(GestureConstants.minimumHeight)
      self.updateCollectionViewFrames(false)
      })
  }

  public func expandGalleryView() {
    UIView.animateWithDuration(0.3, animations: {
      self.updateGalleryViewFrames(GestureConstants.maximumHeight)
      self.updateCollectionViewFrames(true)
      })
  }

  func updateGalleryViewFrames(constant: CGFloat) {
    galleryView.frame.origin.y = totalHeight - bottomContainer.frame.height - constant
    galleryView.frame.size.height = constant
  }

  func updateCollectionViewFrames(maximum: Bool) {
    let constant = maximum ? GestureConstants.maximumHeight : GestureConstants.minimumHeight
    galleryView.collectionViewLayout.invalidateLayout()
    galleryView.collectionView.frame.size.height = constant - galleryView.topSeparator.frame.height
    galleryView.collectionSize = CGSize(width: galleryView.collectionView.frame.height, height: galleryView.collectionView.frame.height)
    galleryView.noImagesLabel.center = galleryView.collectionView.center
  }
}

// MARK: - Action methods

extension ImagePickerController: BottomContainerViewDelegate {

  func pickerButtonDidPress() {
    collapseGalleryView({ [unowned self] in
      self.cameraController.takePicture()
    })
  }

  func doneButtonDidPress() {
    delegate?.doneButtonDidPress?(stack.images)
  }

  func cancelButtonDidPress() {
    dismissViewControllerAnimated(true, completion: nil)
    delegate?.cancelButtonDidPress?()
  }

  func imageStackViewDidPress() {
    delegate?.wrapperDidPress?(stack.images)
  }
}

extension ImagePickerController: CameraViewDelegate {

  func handleFlashButton(hide: Bool) {
    let alpha: CGFloat = hide ? 0 : 1
    UIView.animateWithDuration(0.3, animations: { [unowned self] in
      self.topView.flashButton.alpha = alpha
      })
  }

  func imageToLibrary(image: UIImage) {
    galleryView.images.insertObject(image, atIndex: 0)
    stack.pushImage(image)
    galleryView.shouldTransform = true

    UIView.animateWithDuration(0.3, animations: { [unowned self] in
      self.galleryView.collectionView.transform = CGAffineTransformMakeTranslation(self.galleryView.collectionSize.width, 0)
      }, completion: { _ in
        self.galleryView.collectionView.transform = CGAffineTransformIdentity
        self.galleryView.collectionView.reloadData()
    })
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
    galleryView.alpha = 0
    bottomContainer.pickerButton.enabled = false
    bottomContainer.tapGestureRecognizer.enabled = false
    topView.flashButton.enabled = false
    topView.rotateCamera.enabled = false
  }

  func permissionGranted() {
    galleryView.fetchPhotos(0)
    cameraController.initializeCamera()
    galleryView.alpha = 1
    bottomContainer.pickerButton.enabled = true
    bottomContainer.tapGestureRecognizer.enabled = true
    topView.flashButton.enabled = true
    topView.rotateCamera.enabled = true
  }

  func presentViewController(controller: UIAlertController) {
    presentViewController(controller, animated: true, completion: nil)
  }

  func dismissViewController(controller: UIAlertController) {
    dismissViewControllerAnimated(true, completion: nil)
  }

  func panGestureDidStart() {
    initialFrame = galleryView.frame
    initialContentOffset = galleryView.collectionView.contentOffset
    numberOfCells = Int(initialContentOffset.x / galleryView.collectionSize.width)
  }

  func panGestureDidChange(translation: CGPoint) {
    let galleryHeight = initialFrame.height - translation.y

    if galleryHeight <= ImageGalleryView.Dimensions.galleryBarHeight {
      updateGalleryViewFrames(ImageGalleryView.Dimensions.galleryBarHeight)
    } else if galleryHeight >= GestureConstants.maximumHeight {
      updateGalleryViewFrames(GestureConstants.maximumHeight)
    } else {
      galleryView.frame.origin.y = initialFrame.origin.y + translation.y
      galleryView.frame.size.height = initialFrame.height - translation.y
    }

    if galleryHeight > GestureConstants.minimumHeight {
      galleryView.collectionViewLayout.invalidateLayout()
      galleryView.collectionView.frame.size.height = galleryView.frame.size.height - ImageGalleryView.Dimensions.galleryBarHeight
      galleryView.collectionSize = CGSize(width: galleryView.collectionView.frame.height, height: galleryView.collectionView.frame.height)

      if galleryHeight < GestureConstants.maximumHeight {
        galleryView.collectionView.contentOffset = CGPoint(x: initialContentOffset.x - (translation.y * CGFloat(numberOfCells)), y: 0)
      }
    }

    galleryView.noImagesLabel.center = galleryView.collectionView.center
  }

  func panGestureDidEnd(translation: CGPoint, location: CGPoint, velocity: CGPoint) {
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
