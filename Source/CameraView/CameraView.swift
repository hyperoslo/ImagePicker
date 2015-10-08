import UIKit
import AVFoundation
import AssetsLibrary

protocol CameraViewDelegate: class {

  func handleFlashButton(hide: Bool)
  func imageToLibrary()
}

class CameraView: UIViewController {

  lazy var pickerConfiguration: Configuration = Configuration.sharedInstance

  lazy var blurView: UIVisualEffectView = { [unowned self] in
    let effect = UIBlurEffect(style: .Dark)
    let blurView = UIVisualEffectView(effect: effect)
    self.containerView.addSubview(blurView)

    return blurView
    }()

  lazy var focusImageView: UIImageView = { [unowned self] in
    let imageView = UIImageView()
    imageView.image = self.getImage("focusIcon")
    imageView.backgroundColor = .clearColor()
    imageView.frame = CGRectMake(0, 0, 110, 110)
    imageView.alpha = 0
    self.view.addSubview(imageView)

    return imageView
    }()

  lazy var capturedImageView: UIView = { [unowned self] in
    let view = UIView()
    view.backgroundColor = .blackColor()
    view.alpha = 0
    self.view.addSubview(view)

    return view
    }()

  lazy var containerView: UIView = {
    let view = UIView()
    view.alpha = 0

    return view
    }()

  let captureSession = AVCaptureSession()
  let devices = AVCaptureDevice.devices()
  var captureDevice: AVCaptureDevice?
  var capturedDevices: NSMutableArray?
  var previewLayer: AVCaptureVideoPreviewLayer?
  weak var delegate: CameraViewDelegate?
  var stillImageOutput: AVCaptureStillImageOutput?
  var animationTimer: NSTimer?

  override func viewDidLoad() {
    super.viewDidLoad()

    initializeCamera()
    
    view.backgroundColor = self.pickerConfiguration.mainColor
    previewLayer?.backgroundColor = self.pickerConfiguration.mainColor.CGColor
  }

  // MARK: - Initialize camera

  func initializeCamera() {
    captureSession.sessionPreset = AVCaptureSessionPreset1920x1080
    capturedDevices = NSMutableArray()

    let authorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)

    for device in devices {
      if let device = device as? AVCaptureDevice {
        if device.hasMediaType(AVMediaTypeVideo) && authorizationStatus == .Authorized {
          captureDevice = device
          capturedDevices?.addObject(device)
        } else if device.hasMediaType(AVMediaTypeVideo) && authorizationStatus == .NotDetermined {
          AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo,
            completionHandler: { (granted: Bool) -> Void in
              if granted {
                self.captureDevice = device
                self.capturedDevices?.addObject(device)
              }
          })
        }

      }
    }

    captureDevice = capturedDevices?.firstObject as? AVCaptureDevice

    if captureDevice != nil {
      beginSession()
    }
  }

  // MARK: - Camera actions

  func rotateCamera() {
    guard let captureDevice = captureDevice else { return }
    let deviceIndex = capturedDevices?.indexOfObject(captureDevice)
    let currentDeviceInput = captureSession.inputs.first as! AVCaptureDeviceInput
    var newDeviceIndex = 0

    blurView.frame = view.bounds
    containerView.frame = view.bounds
    view.addSubview(containerView)

    if let index = capturedDevices?.count {
      if deviceIndex != index - 1 && deviceIndex < capturedDevices?.count {
        newDeviceIndex = deviceIndex! + 1
      }
    }

    self.captureDevice = capturedDevices?.objectAtIndex(newDeviceIndex) as? AVCaptureDevice
    configureDevice()

    delegate?.handleFlashButton(captureDevice.position == .Front)

    guard let currentCaptureDevice = self.captureDevice else { return }
    UIView.animateWithDuration(0.3, animations: { [unowned self] in
      self.containerView.alpha = 1
      }, completion: { finished in
        self.captureSession.beginConfiguration()
        self.captureSession.removeInput(currentDeviceInput)

        if currentCaptureDevice.supportsAVCaptureSessionPreset(AVCaptureSessionPreset1280x720) {
          self.captureSession.sessionPreset = AVCaptureSessionPreset1280x720
        } else {
          self.captureSession.sessionPreset = AVCaptureSessionPreset640x480
        }

        try! self.captureSession.addInput(AVCaptureDeviceInput(device: self.captureDevice))
        self.captureSession.commitConfiguration()
        UIView.animateWithDuration(0.7, animations: { [unowned self] in
          self.containerView.alpha = 0
          })
    })
  }

  func flashCamera(title: String) {

    if (captureDevice?.hasFlash != nil) {
      do {
        try captureDevice?.lockForConfiguration()
      } catch _ {
      }
      switch title {
      case "ON":
        captureDevice?.flashMode = .On
      case "OFF":
        captureDevice?.flashMode = .Off
      default:
        captureDevice?.flashMode = .Auto
        
      }
    }
  }

  func takePicture() {
    capturedImageView.frame = view.bounds

    UIView.animateWithDuration(0.1, animations: {
      self.capturedImageView.alpha = 1
      }, completion: { _ in
        UIView.animateWithDuration(0.1, animations: {
          self.capturedImageView.alpha = 0
        })
    })

    let queue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL)

    if let videoOrientation = previewLayer?.connection.videoOrientation {
      stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo).videoOrientation = videoOrientation
    }

    guard let stillImageOutput = self.stillImageOutput else { return }

    dispatch_async(queue, { [unowned self] in
      stillImageOutput.captureStillImageAsynchronouslyFromConnection(stillImageOutput.connectionWithMediaType(AVMediaTypeVideo),
        completionHandler: { (buffer, error) -> Void in
          let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
          guard let imageFromData = UIImage(data: imageData) else { return }
          let image = self.cropImage(imageFromData)
          let orientation = self.pictureOrientation()
          let assetsLibrary = ALAssetsLibrary()
          assetsLibrary.writeImageToSavedPhotosAlbum(image.CGImage, orientation: orientation) { url, error in
            self.delegate?.imageToLibrary()
          }
      })
      })
  }

  func cropImage(image: UIImage) -> UIImage {
    guard let imageReference = CGImageCreateWithImageInRect(image.CGImage,
      CGRect(x: 0, y: 0, width: image.size.height - 285, height: image.size.width)) else { return UIImage() }
    let normalizedImage = UIImage(CGImage: imageReference, scale: 1, orientation: .Right)

    return normalizedImage
  }

  func pictureOrientation() -> ALAssetOrientation {
    switch UIDevice.currentDevice().orientation {
    case .LandscapeLeft:
      return .Up
    case .LandscapeRight:
      return .Down
    case .PortraitUpsideDown:
      return .Left
    default:
      return .Right
    }
  }

  // MARK: - Timer methods

  func timerDidFire() {
    UIView.animateWithDuration(0.3, animations: { [unowned self] in
      self.focusImageView.alpha = 0
      }) { _ in
        self.focusImageView.transform = CGAffineTransformIdentity
    }
  }

  // MARK: - Camera methods

  func focusTo(point: CGPoint) {
    guard let device = captureDevice else { return }
    do { try device.lockForConfiguration() } catch {
      print("Couldn't lock configuration")
    }

    if device.isFocusModeSupported(AVCaptureFocusMode.Locked) {
      device.focusPointOfInterest = CGPointMake(point.x / UIScreen.mainScreen().bounds.width, point.y / UIScreen.mainScreen().bounds.height)
      device.unlockForConfiguration()
      focusImageView.center = point
      UIView.animateWithDuration(0.5, animations: { [unowned self] in
        self.focusImageView.alpha = 1
        self.focusImageView.transform = CGAffineTransformMakeScale(0.6, 0.6)
        }, completion: { _ in
          self.animationTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self,
            selector: "timerDidFire", userInfo: nil, repeats: false)
      })
    }
  }

  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard let firstTouch = touches.first else { return }
    let anyTouch = firstTouch
    let touchX = anyTouch.locationInView(view).x
    let touchY = anyTouch.locationInView(view).y
    focusImageView.transform = CGAffineTransformIdentity
    animationTimer?.invalidate()
    focusTo(CGPointMake(touchX, touchY))
  }

  func configureDevice() {
    if let device = captureDevice {
      do {
        try device.lockForConfiguration()
      } catch _ {
        print("Couldn't lock configuration")
      }
      device.unlockForConfiguration()
    }
  }

  func beginSession() {
    configureDevice()
    guard captureSession.inputs.count == 0 else { return }

    let captureDeviceInput: AVCaptureDeviceInput?
    do { try
      captureDeviceInput = AVCaptureDeviceInput(device: self.captureDevice)
      captureSession.addInput(captureDeviceInput)
    } catch {
      print("Failed to capture device")
    }

    guard let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) else { return }
    self.previewLayer = previewLayer
    previewLayer.autoreverses = true
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    view.layer.addSublayer(previewLayer)
    previewLayer.frame = view.layer.frame
    view.clipsToBounds = true
    captureSession.startRunning()
    delegate?.handleFlashButton(captureDevice?.position == .Front)
    stillImageOutput = AVCaptureStillImageOutput()
    stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
    captureSession.addOutput(stillImageOutput)
  }

  // MARK: - Private helpers

  func getImage(name: String) -> UIImage {
    let bundlePath = NSBundle(forClass: self.classForCoder).resourcePath?.stringByAppendingString("/ImagePicker.bundle")
    let bundle = NSBundle(path: bundlePath!)
    let traitCollection = UITraitCollection(displayScale: 3)

    guard let image = UIImage(named: name, inBundle: bundle, compatibleWithTraitCollection: traitCollection) else { return UIImage() }

    return image
  }
}
