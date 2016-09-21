import UIKit
import AVFoundation
import PhotosUI

protocol CameraViewDelegate: class {

  func setFlashButtonHidden(_ hidden: Bool)
  func imageToLibrary()
  func cameraNotAvailable()
}

class CameraView: UIViewController, CLLocationManagerDelegate, CameraManDelegate {

  lazy var blurView: UIVisualEffectView = { [unowned self] in
    let effect = UIBlurEffect(style: .dark)
    let blurView = UIVisualEffectView(effect: effect)

    return blurView
    }()

  lazy var focusImageView: UIImageView = { [unowned self] in
    let imageView = UIImageView()
    imageView.image = AssetManager.getImage("focusIcon")
    imageView.backgroundColor = UIColor.clear
    imageView.frame = CGRect(x: 0, y: 0, width: 110, height: 110)
    imageView.alpha = 0

    return imageView
    }()

  lazy var capturedImageView: UIView = { [unowned self] in
    let view = UIView()
    view.backgroundColor = UIColor.black
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
    let button = UIButton(type: .system)
    let title = NSAttributedString(string: Configuration.settingsTitle,
      attributes: [
        NSFontAttributeName : Configuration.settingsFont,
        NSForegroundColorAttributeName : Configuration.settingsColor,
      ])

    button.setAttributedTitle(title, for: UIControlState())
    button.contentEdgeInsets = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
    button.sizeToFit()
    button.layer.borderColor = Configuration.settingsColor.cgColor
    button.layer.borderWidth = 1
    button.layer.cornerRadius = 4
    button.addTarget(self, action: #selector(settingsButtonDidTap), for: .touchUpInside)

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
  var animationTimer: Timer?
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

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    previewLayer?.connection.videoOrientation = .portrait
    locationManager?.startUpdatingLocation()
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    locationManager?.stopUpdatingLocation()
  }

  func setupPreviewLayer() {
    guard let layer = AVCaptureVideoPreviewLayer(session: cameraMan.session) else { return }

    layer.backgroundColor = Configuration.mainColor.cgColor
    layer.autoreverses = true
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill

    view.layer.insertSublayer(layer, at: 0)
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
    DispatchQueue.main.async {
      if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
        UIApplication.shared.openURL(settingsURL)
      }
    }
  }

  // MARK: - Camera actions

  func rotateCamera() {
    UIView.animate(withDuration: 0.3, animations: { _ in
      self.containerView.alpha = 1
      }, completion: { _ in
        self.cameraMan.switchCamera {
          UIView.animate(withDuration: 0.7, animations: {
            self.containerView.alpha = 0
          }) 
        }
    })
  }

  func flashCamera(_ title: String) {
    let mapping: [String: AVCaptureFlashMode] = [
      "ON": .on,
      "OFF": .off
    ]

    cameraMan.flash(mapping[title] ?? .auto)
  }

  func takePicture(_ completion: @escaping () -> ()) {
    guard let previewLayer = previewLayer else { return }

    UIView.animate(withDuration: 0.1, animations: {
      self.capturedImageView.alpha = 1
      }, completion: { _ in
        UIView.animate(withDuration: 0.1, animations: {
          self.capturedImageView.alpha = 0
        }) 
    })

    cameraMan.takePhoto(previewLayer, location: locationManager?.latestLocation) {
      completion()
      self.delegate?.imageToLibrary()
    }
  }

  // MARK: - Timer methods

  func timerDidFire() {
    UIView.animate(withDuration: 0.3, animations: { [unowned self] in
      self.focusImageView.alpha = 0
      }, completion: { _ in
        self.focusImageView.transform = CGAffineTransform.identity
    })
  }

  // MARK: - Camera methods

  func focusTo(_ point: CGPoint) {
    let convertedPoint = CGPoint(x: point.x / UIScreen.main.bounds.width,
                                 y:point.y / UIScreen.main.bounds.height)

    cameraMan.focus(convertedPoint)

    focusImageView.center = point
    UIView.animate(withDuration: 0.5, animations: { _ in
      self.focusImageView.alpha = 1
      self.focusImageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
      }, completion: { _ in
        self.animationTimer = Timer.scheduledTimer(timeInterval: 1, target: self,
          selector: #selector(CameraView.timerDidFire), userInfo: nil, repeats: false)
    })
  }

  // MARK: - Tap

  func tapGestureRecognizerHandler(_ gesture: UITapGestureRecognizer) {
    let touch = gesture.location(in: view)

    focusImageView.transform = CGAffineTransform.identity
    animationTimer?.invalidate()
    focusTo(touch)
  }

  // MARK: - Private helpers

  func showNoCamera(_ show: Bool) {
    [noCameraButton, noCameraLabel].forEach {
      show ? view.addSubview($0) : $0.removeFromSuperview()
    }
  }

  // CameraManDelegate
  func cameraManNotAvailable(_ cameraMan: CameraMan) {
    showNoCamera(true)
    focusImageView.isHidden = true
    delegate?.cameraNotAvailable()
  }

  func cameraMan(_ cameraMan: CameraMan, didChangeInput input: AVCaptureDeviceInput) {
    delegate?.setFlashButtonHidden(!input.device.hasFlash)
  }

  func cameraManDidStart(_ cameraMan: CameraMan) {
    setupPreviewLayer()
  }
}
