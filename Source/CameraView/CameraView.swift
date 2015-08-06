import UIKit
import AVFoundation

class CameraView: UIViewController {

  lazy var configuration: PickerConfiguration = {
    let configuration = PickerConfiguration()
    return configuration
    }()

  let captureSession = AVCaptureSession()
  let devices = AVCaptureDevice.devices()
  var captureDevice: AVCaptureDevice?
  var previewLayer : AVCaptureVideoPreviewLayer?

  override func viewDidLoad() {
    super.viewDidLoad()
    captureSession.sessionPreset = AVCaptureSessionPreset640x480
    for device in devices {
      if device.hasMediaType(AVMediaTypeVideo) {
        captureDevice = device as? AVCaptureDevice
      }
    }

    if captureDevice != nil {
      beginSession()
    }

    view.backgroundColor = self.configuration.backgroundColor
  }

  // MARK: - Camera actions

  func rotateCamera() {

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
