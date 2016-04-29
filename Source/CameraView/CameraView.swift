import UIKit
import AVFoundation
import PhotosUI

protocol CameraViewDelegate: class {

  func setFlashButtonHidden(hidden: Bool)
  func imageToLibrary()
  func cameraNotAvailable()
}

class CameraView: UIViewController, CLLocationManagerDelegate, CameraManDelegate {

  lazy var blurView: UIVisualEffectView = { [unowned self] in
    let effect = UIBlurEffect(style: .Dark)
    let blurView = UIVisualEffectView(effect: effect)

    return blurView
    }()

  lazy var focusImageView: UIImageView = { [unowned self] in
    let imageView = UIImageView()
    imageView.image = AssetManager.getImage("focusIcon")
    imageView.backgroundColor = .clearColor()
    imageView.frame = CGRectMake(0, 0, 110, 110)
    imageView.alpha = 0

    return imageView
    }()

  lazy var capturedImageView: UIView = { [unowned self] in
    let view = UIView()
    view.backgroundColor = .blackColor()
    view.alpha = 0

    return view
    }()

  lazy var containerView: UIView = {
    let view = UIView()
    view.alpha = 0

    return view
  }()

  lazy var noCameraLabel: UILabel = { [unowned self] in
    let label = UILabel()
    label.font = Configuration.noCameraFont
    label.textColor = Configuration.noCameraColor
    label.text = Configuration.noCameraTitle
    label.sizeToFit()

    return label
    }()

  lazy var noCameraButton: UIButton = { [unowned self] in
    let button = UIButton(type: .System)
    let title = NSAttributedString(string: Configuration.settingsTitle,
      attributes: [
        NSFontAttributeName : Configuration.settingsFont,
        NSForegroundColorAttributeName : Configuration.settingsColor,
      ])

    button.setAttributedTitle(title, forState: .Normal)
    button.contentEdgeInsets = UIEdgeInsetsMake(5.0, 10.0, 5.0, 10.0)
    button.sizeToFit()
    button.layer.borderColor = Configuration.settingsColor.CGColor
    button.layer.borderWidth = 1
    button.layer.cornerRadius = 4
    button.addTarget(self, action: #selector(settingsButtonDidTap), forControlEvents: .TouchUpInside)

    return button
    }()

  lazy var tapGestureRecognizer: UITapGestureRecognizer = { [unowned self] in
    let gesture = UITapGestureRecognizer()
    gesture.addTarget(self, action: #selector(tapGestureRecognizerHandler(_:)))

    return gesture
    }()

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
    setCorrectOrientationToPreviewLayer()
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
                                 y:point.y / UIScreen.mainScreen().bounds.height)

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

  override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

    previewLayer?.frame.size = size
    setCorrectOrientationToPreviewLayer()
  }

  func setCorrectOrientationToPreviewLayer() {
    guard let previewLayer = self.previewLayer,
      connection = previewLayer.connection
      else { return }

    switch UIDevice.currentDevice().orientation {
    case .Portrait:
      connection.videoOrientation = .Portrait
    case .LandscapeLeft:
      connection.videoOrientation = .LandscapeRight
    case .LandscapeRight:
      connection.videoOrientation = .LandscapeLeft
    case .PortraitUpsideDown:
      connection.videoOrientation = .PortraitUpsideDown
    default:
      break
    }
  }

  // CameraManDelegate
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
