import UIKit
import AVFoundation

class CameraView: UIViewController {

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

    view.backgroundColor = UIColor.redColor()
  }

  // MARK: - Camera actions

  func rotateCamera() {

  }

  func flashCamera(title: String) {

  }

  // MARK: - Camera methods

  func focusTo(value : Float) {
    if let device = captureDevice {
      if(device.lockForConfiguration(nil)) {
        device.setFocusModeLockedWithLensPosition(value, completionHandler: { (time) -> Void in
          //
        })
        device.unlockForConfiguration()
      }
    }
  }

  let screenWidth = UIScreen.mainScreen().bounds.size.width

  override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    var anyTouch = touches.first as! UITouch
    var touchPercent = anyTouch.locationInView(self.view).x / screenWidth
    focusTo(Float(touchPercent))
  }

  override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
    var anyTouch = touches.first as! UITouch
    var touchPercent = anyTouch.locationInView(self.view).x / screenWidth
    focusTo(Float(touchPercent))
  }

  func configureDevice() {
    if let device = captureDevice {
      device.lockForConfiguration(nil)
      device.focusMode = .Locked
      device.unlockForConfiguration()
    }

  }

  func beginSession() {
    configureDevice()
    var err : NSError? = nil
    captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))

    if err != nil {
      println("error: \(err?.localizedDescription)")
    }

    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    self.view.layer.addSublayer(previewLayer)
    previewLayer?.frame = self.view.layer.frame
    captureSession.startRunning()
  }
}
