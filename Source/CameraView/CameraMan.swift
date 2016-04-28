import Foundation
import AVFoundation
import PhotosUI

protocol CameraManDelegate: class {
  func cameraManNotAvailable(cameraMan: CameraMan)
  func cameraManWillStart(cameraMan: CameraMan)
  func cameraMan(cameraMan: CameraMan, didChangeInput input: AVCaptureDeviceInput)
}

class CameraMan {
  weak var delegate: CameraManDelegate?

  let session = AVCaptureSession()
  let queue = dispatch_queue_create("no.hyper.ImagePicker.Camera.SessionQueue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0))

  var backCamera: AVCaptureDeviceInput?
  var frontCamera: AVCaptureDeviceInput?
  var stillImageOutput: AVCaptureStillImageOutput?

  deinit {
    stop()
  }

  // MARK: - Setup

  func start() {
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

  func addInput(input: AVCaptureDeviceInput) {
    configurePreset(input)

    if session.canAddInput(input) {
      session.addInput(input)
      delegate?.cameraMan(self, didChangeInput: input)
    }
  }

  // MARK: - Permission

  func checkPermission() {
    let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)

    switch status {
    case .Authorized:
      setup()
    case .NotDetermined:
      requestPermission()
    default:
      delegate?.cameraManNotAvailable(self)
    }
  }

  func requestPermission() {
    AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { granted in
      dispatch_async(dispatch_get_main_queue()) {
        if granted {
          self.setup()
        } else {
          self.delegate?.cameraManNotAvailable(self)
        }
      }
    }
  }

  // MARK: - Session

  var currentInput: AVCaptureDeviceInput? {
    return session.inputs.first as? AVCaptureDeviceInput
  }

  private func setup() {
    // Devices
    setupDevices()

    guard let input = backCamera, output = stillImageOutput else { return }

    addInput(input)

    if session.canAddOutput(output) {
      session.addOutput(output)
    }

    self.delegate?.cameraManWillStart(self)

    dispatch_async(queue) {
      self.session.startRunning()
    }
  }

  func stop() {
    dispatch_async(queue) {
      self.session.stopRunning()
    }
  }

  func switchCamera(completion: (() -> Void)? = nil) {
    guard let currentInput = currentInput else { return }

    dispatch_async(queue) {
      guard let input = (currentInput == self.backCamera) ? self.frontCamera : self.backCamera
        else {
          completion?()
          return
      }

      self.session.beginConfiguration()
      self.session.removeInput(currentInput)
      self.addInput(input)
      self.session.commitConfiguration()

      dispatch_async(dispatch_get_main_queue()) {
        completion?()
      }
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

  func flash(mode: AVCaptureFlashMode) {
    dispatch_async(queue) {
      self.configure {
        self.currentInput?.device.flashMode = mode
      }
    }
  }

  func focus(point: CGPoint) {
    guard let device = currentInput?.device where device.isFocusModeSupported(AVCaptureFocusMode.Locked) else { return }

    configure {
      device.focusPointOfInterest = point
    }
  }

  // MARK: - Configure

  func configure(block: () -> Void) {
    if let device = currentInput?.device where (try? device.lockForConfiguration()) != nil {
      block()
      device.unlockForConfiguration()
    }
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
