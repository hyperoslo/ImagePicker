import UIKit
import AVFoundation
import AssetsLibrary

protocol CameraViewDelegate {

  func handleFlashButton(hide: Bool)
  func imageToLibrary(image: UIImage)
}

class CameraView: UIViewController {

  lazy var configuration: PickerConfiguration = {
    let configuration = PickerConfiguration()
    return configuration
    }()

  lazy var blurView: UIVisualEffectView = { [unowned self] in
    let effect = UIBlurEffect(style: .Dark)
    let blurView = UIVisualEffectView(effect: effect)
    self.containerView.addSubview(blurView)

    return blurView
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
  var delegate: CameraViewDelegate?
  var stillImageOutput: AVCaptureStillImageOutput?

  override func viewDidLoad() {
    super.viewDidLoad()
    captureSession.sessionPreset = AVCaptureSessionPreset640x480
    capturedDevices = NSMutableArray()
    for device in devices {
      if device.hasMediaType(AVMediaTypeVideo) {
        captureDevice = device as? AVCaptureDevice
        capturedDevices?.addObject(device as! AVCaptureDevice)
      }
    }

    if captureDevice != nil {
      beginSession()
    }

    view.backgroundColor = self.configuration.mainColor
    previewLayer?.backgroundColor = self.configuration.mainColor.CGColor
  }

  // MARK: - Camera actions

  func rotateCamera() {
    let deviceIndex = capturedDevices?.indexOfObject(captureDevice!)
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

    captureDevice = capturedDevices?.objectAtIndex(newDeviceIndex) as? AVCaptureDevice
    configureDevice()

    delegate?.handleFlashButton(captureDevice?.position == .Front)

    var error: NSError? = nil

    UIView.animateWithDuration(0.3, animations: { [unowned self] in
      self.containerView.alpha = 1
      }, completion: { finished in
        self.captureSession.beginConfiguration()
        self.captureSession.removeInput(currentDeviceInput)
        self.captureSession.addInput(AVCaptureDeviceInput(device: self.captureDevice, error: &error))
        self.captureSession.commitConfiguration()
        UIView.animateWithDuration(1.3, animations: { [unowned self] in
          self.containerView.alpha = 0
          })
    })
  }

  func flashCamera(title: String) {
    if captureDevice!.hasFlash {
      captureDevice?.lockForConfiguration(nil)
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
    let queue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL)
    let videoOrientation = previewLayer?.connection.videoOrientation
    stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo).videoOrientation = videoOrientation!

    dispatch_async(queue, { [unowned self] in
      self.stillImageOutput!.captureStillImageAsynchronouslyFromConnection(self.stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo), completionHandler: { (buffer, error) -> Void in
        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
        let image = UIImage(data: imageData)
        self.delegate?.imageToLibrary(image!)
        let orientation = ALAssetOrientation(rawValue: image!.imageOrientation.rawValue)
        let assetsLibrary = ALAssetsLibrary()
        assetsLibrary.writeImageToSavedPhotosAlbum(image!.CGImage, orientation: orientation!, completionBlock: nil)
      })
    })
  }

  // MARK: - Camera methods

  func focusTo(point: CGPoint) {
    if let device = captureDevice {
      if device.lockForConfiguration(nil) && device.isFocusModeSupported(AVCaptureFocusMode.Locked) {
        device.focusPointOfInterest = point
        device.unlockForConfiguration()
      }
    }
  }

  override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    let anyTouch = touches.first as! UITouch
    let touchX = anyTouch.locationInView(view).x / UIScreen.mainScreen().bounds.size.width
    let touchY = anyTouch.locationInView(view).y / UIScreen.mainScreen().bounds.size.height
    focusTo(CGPointMake(touchX, touchY))
  }

  override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
    let anyTouch = touches.first as! UITouch
    let touchX = anyTouch.locationInView(view).x / UIScreen.mainScreen().bounds.size.width
    let touchY = anyTouch.locationInView(view).y / UIScreen.mainScreen().bounds.size.height
    focusTo(CGPointMake(touchX, touchY))
  }

  func configureDevice() {
    if let device = captureDevice {
      device.lockForConfiguration(nil)
      device.unlockForConfiguration()
    }
  }

  func beginSession() {
    configureDevice()
    var error: NSError? = nil
    captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &error))

    if error != nil {
      println("error: \(error?.localizedDescription)")
    }

    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer?.autoreverses = true
    previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
    view.clipsToBounds = true
    view.layer.addSublayer(previewLayer)
    previewLayer?.frame = view.layer.frame
    captureSession.startRunning()
    delegate?.handleFlashButton(captureDevice?.position == .Front)
    stillImageOutput = AVCaptureStillImageOutput()
    stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
    captureSession.addOutput(stillImageOutput)
  }
}
