import Foundation
import AVFoundation
import PhotosUI

class CameraMan {

  let session = AVCaptureSession()
  let queue = dispatch_queue_create("no.hyper.ImagePicker.Camera.SessionQueue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0))

  var backCamera: AVCaptureDeviceInput?
  var frontCamera: AVCaptureDeviceInput?
  var stillImageOutput: AVCaptureStillImageOutput?

  var noCameraHandler: (() -> Void)?

  deinit {
    stop()
  }

  // MARK: - Setup

  func setup() {
    checkPermission()
  }

  func setupDevices() {
    // Input
    AVCaptureDevice
    .devices().flatMap {
      return $0 as? AVCaptureDevice
    }.filter {
      return $0.hasMediaType(AVMediaTypeVideo)
    }.forEach {
      switch $0.position {
      case .Front:
        self.frontCamera = try? AVCaptureDeviceInput(device: $0)
      case .Back:
        self.backCamera = try? AVCaptureDeviceInput(device: $0)
      default:
        break
      }
    }

    // Output
    stillImageOutput = AVCaptureStillImageOutput()
    stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
  }

  // MARK: - Permission

  func checkPermission() {
    let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)

    switch status {
    case .Authorized:
      setupDevices()
    case .NotDetermined:
      requestPermission()
    default:
      noCameraHandler?()
    }
  }

  func requestPermission() {
    AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { granted in
      dispatch_async(dispatch_get_main_queue()) {
        if granted {
          self.setupDevices()
        } else {
          self.noCameraHandler?()
        }
      }
    }
  }

  // MARK: - Session

  func start() {
    guard let input = backCamera, output = stillImageOutput else { return }

    configurePreset(input)

    if session.canAddInput(input) {
      session.addInput(input)
    }

    if session.canAddOutput(output) {
      session.addOutput(output)
    }

    dispatch_async(queue) {
      self.session.startRunning()
    }
  }

  func stop() {
    dispatch_async(queue) {
      self.session.stopRunning()
    }
  }

  func switchCamera() {
    guard let currentInput = session.inputs.first as? AVCaptureDeviceInput else { return }

    dispatch_async(queue) {
      self.session.beginConfiguration()

      guard let input = (currentInput == self.backCamera) ? self.frontCamera : self.backCamera else { return }

      self.session.removeInput(currentInput)
      self.configurePreset(input)
      self.session.addInput(input)

      self.session.commitConfiguration()
    }
  }

  func takePhoto(previewLayer: AVCaptureVideoPreviewLayer, location: CLLocation?, completion: (() -> Void)? = nil) {
    guard let connection = stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo) else { return }

    connection.videoOrientation = previewLayer.connection.videoOrientation

    dispatch_async(queue) {
      self.stillImageOutput?.captureStillImageAsynchronouslyFromConnection(connection) {
        buffer, error in

        guard error == nil && buffer != nil && CMSampleBufferIsValid(buffer),
          let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer),
          image = UIImage(data: imageData)
          else { return }

        self.savePhoto(image, location: location, completion: completion)
      }
    }
  }

  func savePhoto(image: UIImage, location: CLLocation?, completion: (() -> Void)? = nil) {
    PHPhotoLibrary.sharedPhotoLibrary().performChanges({
      let request = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
      request.creationDate = NSDate()
      request.location = location
      }, completionHandler: { _ in
        dispatch_async(dispatch_get_main_queue()) {
          completion?()
        }
    })
  }

  // MARK: - Preset

  func configurePreset(input: AVCaptureDeviceInput) {
    preferredPresets().forEach {
      if input.device.supportsAVCaptureSessionPreset($0) && self.session.canSetSessionPreset($0) {
        self.session.sessionPreset = $0
        return
      }
    }
  }

  func preferredPresets() -> [String] {
    return [
      AVCaptureSessionPresetHigh,
      AVCaptureSessionPresetMedium,
      AVCaptureSessionPresetLow
    ]
  }
}
