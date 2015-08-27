import UIKit

@objc
public protocol ImagePickerDelegate {

  optional func wrapperDidPress(images: [UIImage])
  optional func doneButtonDidPress(images: [UIImage])
  optional func cancelButtonDidPress()
}

public class ImagePickerController: UIViewController {

  struct Dimensions {
    static let bottomContainerHeight: CGFloat = 101
  }

  public var stack = ImageStack()

  lazy public var galleryView: ImageGalleryView = { [unowned self] in
    let galleryView = ImageGalleryView()
    galleryView.backgroundColor = self.configuration.mainColor
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

  public weak var delegate: ImagePickerDelegate?
  var topSeparatorCenter: CGPoint!
  var initialFrame: CGRect!
  var targetIndexPath: NSIndexPath!

  public var doneButtonTitle: String? {
    didSet {
      bottomContainer.doneButton.setTitle(doneButtonTitle!, forState: .Normal)
    }
  }

  // MARK: - View lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    subscribe()

    view.backgroundColor = .whiteColor()

    for subview in [topView, cameraController.view, galleryView, bottomContainer] {
      view.addSubview(subview)
      subview.setTranslatesAutoresizingMaskIntoConstraints(false)
    }

    view.backgroundColor = self.configuration.mainColor

    setupConstraints()
  }

  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    UIApplication.sharedApplication().statusBarHidden = true
  }

  public override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    let screenHeight = UIScreen.mainScreen().nativeBounds.height
    let galleryHeight: CGFloat = screenHeight == 960 ? 34 : 134
    galleryView.frame = CGRectMake(0,
      UIScreen.mainScreen().bounds.height - bottomContainer.frame.height - galleryHeight,
      UIScreen.mainScreen().bounds.width,
      galleryHeight)
    galleryView.updateFrames()
    cameraController.view.frame = CGRectMake(0, 32,
      UIScreen.mainScreen().bounds.width, galleryView.frame.origin.y - 32)
    cameraController.previewLayer?.frame = CGRectMake(0, 0,
      UIScreen.mainScreen().bounds.width, cameraController.view.frame.height)
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


  // MARK: - Autolayout

  func setupConstraints() {
    let attributes: [NSLayoutAttribute] = [.Bottom, .Right, .Width]
    let topViewAttributes: [NSLayoutAttribute] = [.Left, .Top, .Width]

    attributes.map {
      self.view.addConstraint(NSLayoutConstraint(item: self.bottomContainer, attribute: $0,
        relatedBy: .Equal, toItem: self.view, attribute: $0,
        multiplier: 1, constant: 0))
    }

    view.addConstraint(NSLayoutConstraint(item: bottomContainer, attribute: .Height,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: Dimensions.bottomContainerHeight))

    topViewAttributes.map {
      self.view.addConstraint(NSLayoutConstraint(item: self.topView, attribute: $0,
        relatedBy: .Equal, toItem: self.view, attribute: $0,
        multiplier: 1, constant: 0))
    }

    view.addConstraint(NSLayoutConstraint(item: topView, attribute: .Height,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: TopView.Dimensions.height))
  }

  // MARK: - Helpers

  public override func prefersStatusBarHidden() -> Bool {
    return true
  }
}

// MARK: - Action methods

extension ImagePickerController: BottomContainerViewDelegate {

  func pickerButtonDidPress() {
    cameraController.takePicture()
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
    topSeparatorCenter = galleryView.topSeparator.center
    initialFrame = galleryView.frame
    if let cell = galleryView.collectionView.visibleCells().last as? ImageGalleryViewCell {
      targetIndexPath = galleryView.collectionView.indexPathForCell(cell)
      galleryView.collectionView.scrollToItemAtIndexPath(targetIndexPath!, atScrollPosition: .CenteredHorizontally, animated: true)
    }
  }

  func panGestureDidChange(translation: CGPoint, location: CGPoint, velocity: CGPoint) {
    galleryView.frame.size.height = initialFrame.height - translation.y
    galleryView.frame.origin.y = initialFrame.origin.y + translation.y
    galleryView.topSeparator.frame.origin.y = 0

    if galleryView.frame.size.height - galleryView.topSeparator.frame.height > 100 {
      galleryView.collectionViewLayout.invalidateLayout()
      galleryView.collectionView.frame.size.height = galleryView.frame.size.height - galleryView.topSeparator.frame.height
      galleryView.collectionSize = CGSizeMake(galleryView.frame.size.height - galleryView.topSeparator.frame.height, galleryView.frame.size.height - galleryView.topSeparator.frame.height)
      galleryView.collectionView.reloadData()
    } else {
      galleryView.collectionView.frame.origin.y = galleryView.topSeparator.frame.height
    }

    if location.y >= initialFrame.origin.y + initialFrame.height - galleryView.topSeparator.frame.height {
      galleryView.frame.size.height = galleryView.topSeparator.frame.height
      galleryView.frame.origin.y = initialFrame.origin.y + initialFrame.height - galleryView.topSeparator.frame.height
    } else if galleryView.collectionView.frame.height >= ImageGalleryView.Dimensions.galleryHeight {
      galleryView.frame.size.height = ImageGalleryView.Dimensions.galleryHeight + galleryView.topSeparator.frame.height
      galleryView.frame.origin.y = initialFrame.origin.y + initialFrame.height - galleryView.topSeparator.frame.height - ImageGalleryView.Dimensions.galleryHeight
      galleryView.collectionView.frame.size.height = ImageGalleryView.Dimensions.galleryHeight
      galleryView.collectionSize = CGSizeMake(galleryView.collectionView.frame.height, galleryView.collectionView.frame.height)
      galleryView.collectionView.reloadData()
    }

    cameraController.view.frame.size.height = galleryView.frame.origin.y - topView.frame.height
    cameraController.view.frame.origin.y = topView.frame.height
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    cameraController.previewLayer?.frame.size.height = galleryView.frame.origin.y - topView.frame.height
    CATransaction.commit()
    galleryView.noImagesLabel.center = galleryView.collectionView.center
    if let targetIndexPath = targetIndexPath {
      galleryView.collectionView.scrollToItemAtIndexPath(targetIndexPath, atScrollPosition: .CenteredHorizontally, animated: false)
    }
  }

  func panGestureDidEnd(translation: CGPoint, location: CGPoint, velocity: CGPoint) {
    if galleryView.frame.height < 134 && velocity.y < 0 {
      UIView.animateWithDuration(0.2, animations: { [unowned self] in
        self.galleryView.frame.size.height = 134
        self.galleryView.frame.origin.y = self.initialFrame.origin.y + self.initialFrame.height - self.galleryView.topSeparator.frame.height - 100
        self.galleryView.collectionViewLayout.invalidateLayout()
        self.galleryView.collectionView.frame.size.height = 134 - self.galleryView.topSeparator.frame.height
        self.galleryView.collectionSize = CGSizeMake(self.galleryView.collectionView.frame.height, self.galleryView.collectionView.frame.height)
        self.cameraController.view.frame.size.height = self.galleryView.frame.origin.y - self.topView.frame.height
        self.cameraController.view.frame.origin.y = self.topView.frame.height
        self.cameraController.previewLayer?.frame = CGRectMake(0, 0,
          self.cameraController.view.frame.width, self.cameraController.view.frame.height)
        self.galleryView.noImagesLabel.center = self.galleryView.collectionView.center
        }, completion: { finished in
          self.galleryView.collectionView.reloadSections(NSIndexSet(index: 0))
          if let targetIndexPath = self.targetIndexPath {
            self.galleryView.collectionView.scrollToItemAtIndexPath(self.targetIndexPath!, atScrollPosition: .CenteredHorizontally, animated: true)
          }
      })
    } else if velocity.y < -100 {
      UIView.animateWithDuration(0.2, animations: { [unowned self] in
        self.galleryView.frame.size.height = ImageGalleryView.Dimensions.galleryHeight + self.galleryView.topSeparator.frame.height
        self.galleryView.frame.origin.y = self.initialFrame.origin.y + self.initialFrame.height - self.galleryView.topSeparator.frame.height - ImageGalleryView.Dimensions.galleryHeight
        self.galleryView.collectionViewLayout.invalidateLayout()
        self.galleryView.collectionView.frame.size.height = ImageGalleryView.Dimensions.galleryHeight
        self.galleryView.collectionSize = CGSizeMake(self.galleryView.collectionView.frame.height, self.galleryView.collectionView.frame.height)
        self.cameraController.view.frame.size.height = self.galleryView.frame.origin.y - self.topView.frame.height
        self.cameraController.view.frame.origin.y = self.topView.frame.height
        self.cameraController.previewLayer?.frame.size = self.cameraController.view.frame.size
        self.galleryView.noImagesLabel.center = self.galleryView.collectionView.center
        }, completion: { finished in
          self.galleryView.collectionView.reloadSections(NSIndexSet(index: 0))
          if let targetIndexPath = self.targetIndexPath {
            self.galleryView.collectionView.scrollToItemAtIndexPath(targetIndexPath, atScrollPosition: .CenteredHorizontally, animated: true)
          }
      })
    } else if velocity.y > 100 || galleryView.frame.size.height - galleryView.topSeparator.frame.height < 100 {
      UIView.animateWithDuration(0.2, animations: { [unowned self] in
        self.galleryView.frame.size.height = self.galleryView.topSeparator.frame.height
        self.galleryView.frame.origin.y = self.initialFrame.origin.y + self.initialFrame.height - self.galleryView.topSeparator.frame.height
        self.galleryView.collectionViewLayout.invalidateLayout()
        self.galleryView.collectionView.frame.size.height = 100
        self.galleryView.collectionSize = CGSizeMake(self.galleryView.collectionView.frame.height, self.galleryView.collectionView.frame.height)
        self.cameraController.view.frame.size.height = self.galleryView.frame.origin.y - self.topView.frame.height
        self.cameraController.view.frame.origin.y = self.topView.frame.height
        self.cameraController.previewLayer?.frame.size = self.cameraController.view.frame.size
        self.galleryView.noImagesLabel.center = self.galleryView.collectionView.center
        }, completion: { finished in
          self.galleryView.collectionView.reloadSections(NSIndexSet(index: 0))
          self.galleryView.collectionView.scrollToItemAtIndexPath(self.targetIndexPath!, atScrollPosition: .CenteredHorizontally, animated: true)
      })
    }
  }
}
