import UIKit
import AVFoundation

class CameraView: UIViewController {

  lazy var configuration: PickerConfiguration = {
    let configuration = PickerConfiguration()
    return configuration
    }()

  lazy var blurView: UIVisualEffectView = { [unowned self] in
    let effect = UIBlurEffect(style: .Light)
    let blurView = UIVisualEffectView(effect: effect)

    return blurView
    }()

  let captureSession = AVCaptureSession()
  let devices = AVCaptureDevice.devices()
  var captureDevice: AVCaptureDevice?
  var capturedDevices: NSMutableArray?
  var previewLayer: AVCaptureVideoPreviewLayer?

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
    view.addSubview(blurView)

    if let index = capturedDevices?.count {
      if deviceIndex != index - 1 && deviceIndex < capturedDevices?.count {
        newDeviceIndex = deviceIndex! + 1
      }
    }

    captureDevice = capturedDevices?.objectAtIndex(newDeviceIndex) as? AVCaptureDevice
    configureDevice()

    var error: NSError? = nil
    captureSession.beginConfiguration()
    captureSession.removeInput(currentDeviceInput)
    captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &error))
    captureSession.commitConfiguration()

    let animation = CABasicAnimation(keyPath: "transform")
    animation.duration = 0.6
    var transform = CATransform3DConcat(CATransform3DMakeRotation(CGFloat(M_PI), 0, 1, 0), CATransform3DMakeScale(0.98, 0.95, 0.98))
    transform.m34 = CGFloat(1/800)
    animation.toValue = NSValue(CATransform3D: transform)

    view.layer.addAnimation(animation, forKey: "")

    let delay = 0.6 * Double(NSEC_PER_SEC)
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
    dispatch_after(time, dispatch_get_main_queue()) { [unowned self] in
      self.view.layer.transform = CATransform3DIdentity
      self.blurView.removeFromSuperview()
      self.view.layer.removeAllAnimations()
    }
  }

  func flashCamera(title: String) {

  }

  // MARK: - Camera methods

//  func focusTo(value : Float) {
//    if let device = captureDevice {
//      if(device.lockForConfiguration(nil)) {
//        device.setFocusModeLockedWithLensPosition(value, completionHandler: { (time) -> Void in
//          //
//        })
//        device.unlockForConfiguration()
//      }
//    }
//  }

  override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    var anyTouch = touches.first as! UITouch
    var touchPercent = anyTouch.locationInView(self.view).x / UIScreen.mainScreen().bounds.size.width
    //focusTo(Float(touchPercent))
  }

  override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
    var anyTouch = touches.first as! UITouch
    var touchPercent = anyTouch.locationInView(self.view).x / UIScreen.mainScreen().bounds.size.width
    //focusTo(Float(touchPercent))
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
  }
}
