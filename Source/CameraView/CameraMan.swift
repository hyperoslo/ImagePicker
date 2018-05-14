import Foundation
import AVFoundation
import PhotosUI
import ImageIO
import AssetsLibrary
import MobileCoreServices

protocol CameraManDelegate: class {
  func cameraManNotAvailable(_ cameraMan: CameraMan)
  func cameraManDidStart(_ cameraMan: CameraMan)
  func cameraMan(_ cameraMan: CameraMan, didChangeInput input: AVCaptureDeviceInput)
}

class CameraMan {
  weak var delegate: CameraManDelegate?

  let session = AVCaptureSession()
  let queue = DispatchQueue(label: "no.hyper.ImagePicker.Camera.SessionQueue", attributes: .concurrent)

  //  let queue = DispatchQueue(label: "no.hyper.ImagePicker.Camera.SessionQueue", attributes: dispatch_queue_attr_make_with_qos_class(DispatchQueue.Attributes, DispatchQoS.QoSClass.background, 0))

  var backCamera: AVCaptureDeviceInput?
  var frontCamera: AVCaptureDeviceInput?
  var stillImageOutput: AVCaptureStillImageOutput?

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
        case .front:
          self.frontCamera = try? AVCaptureDeviceInput(device: $0)
        case .back:
          self.backCamera = try? AVCaptureDeviceInput(device: $0)
        default:
          break
        }
    }

    // Output
    stillImageOutput = AVCaptureStillImageOutput()
    stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
  }

  func addInput(_ input: AVCaptureDeviceInput) {
    configurePreset(input)

    if session.canAddInput(input) {
      session.addInput(input)

      DispatchQueue.main.async {
        self.delegate?.cameraMan(self, didChangeInput: input)
      }
    }
  }

  // MARK: - Permission

  func checkPermission() {
    let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)

    switch status {
    case .authorized:
      start()
    case .notDetermined:
      requestPermission()
    default:
      delegate?.cameraManNotAvailable(self)
    }
  }

  func requestPermission() {
    AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { granted in
      DispatchQueue.main.async {
        if granted {
          self.start()
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

  fileprivate func start() {
    // Devices
    setupDevices()

    guard let input = backCamera, let output = stillImageOutput else { return }

    addInput(input)

    if session.canAddOutput(output) {
      session.addOutput(output)
    }

    queue.async {
      self.session.startRunning()

      DispatchQueue.main.async {
        self.delegate?.cameraManDidStart(self)
      }
    }
  }

  func stop() {
    self.session.stopRunning()
  }

  func switchCamera(_ completion: (() -> Void)? = nil) {
    guard let currentInput = currentInput
      else {
        completion?()
        return
    }

    queue.async {
      guard let input = (currentInput == self.backCamera) ? self.frontCamera : self.backCamera
        else {
          DispatchQueue.main.async {
            completion?()
          }
          return
      }

      self.configure {
        self.session.removeInput(currentInput)
        self.addInput(input)
      }

      DispatchQueue.main.async {
        completion?()
      }
    }
  }

  func takePhoto(_ previewLayer: AVCaptureVideoPreviewLayer, location: CLLocation?, completion: (() -> Void)? = nil) {
    guard let connection = stillImageOutput?.connection(withMediaType: AVMediaTypeVideo) else { return }

    connection.videoOrientation = Helper.videoOrientation()

    queue.async {
      self.stillImageOutput?.captureStillImageAsynchronously(from: connection) {
        buffer, error in

        guard error == nil && buffer != nil && CMSampleBufferIsValid(buffer!),
          let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
          else {
            DispatchQueue.main.async {
              completion?()
            }
            return
        }
        self.savePhoto(imageData, location: location, completion: completion)

      }
    }
  }


  // combine exif dictionaries
  func addGPSToEXIF( old :inout [String: Any], new:[String: Any]) -> [String: Any] {
    old[kCGImagePropertyGPSDictionary as String] = new
    return old
  }


  private func getGPSDictionary(location: CLLocation) -> [String: Double] {
    let dictionary = [kCGImagePropertyGPSLatitude as String :location.coordinate.latitude, kCGImagePropertyGPSLongitude as String :location.coordinate.longitude]
    return dictionary
  }


  // Attach EXIF DIctionary data to an image
  func attachEXIFtoImage(image: Data, EXIF: [String: Any]) -> Data? {

    if let imageDataProvider = CGDataProvider(data: image as CFData),
      let imageRef = CGImage(jpegDataProviderSource: imageDataProvider, decode: nil, shouldInterpolate: true, intent: .defaultIntent),
      let newImageData = CFDataCreateMutable(nil, 0),
      let type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, "image/jpeg" as CFString, kUTTypeImage),
      let destination = CGImageDestinationCreateWithData(newImageData, type.takeRetainedValue(), 1, nil) {
      CGImageDestinationAddImage(destination, imageRef, EXIF as CFDictionary)
      CGImageDestinationFinalize(destination)
      return newImageData as Data
    }
    return nil
  }


  func savePhoto(_ imageData: Data, location: CLLocation?, completion: (() -> Void)? = nil) {
    PHPhotoLibrary.shared().performChanges({

      if let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil),
        var currentProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] {
        if let location = location {
          currentProperties[kCGImagePropertyGPSDictionary as String] = self.getGPSDictionary(location: location)
        }

        if let attached = self.attachEXIFtoImage(image: imageData, EXIF: currentProperties) {

          let dirPathNoScheme = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
          let dirPath = "file://\(dirPathNoScheme)"
          let dataPath = URL(string: dirPath)

          do {
            if let fileExists = try dataPath?.checkResourceIsReachable() {
              if fileExists {
                let formatter = DateFormatter()
                formatter.dateFormat = "Y-M-dd_HH-mm-ss"
                let time = formatter.string(from: Date())
                if let savefilepath = dataPath?.appendingPathComponent(time+".jpg") {
                  try? attached.write(to: savefilepath)
                  let request = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: savefilepath)
                  request?.creationDate = Date()
                  request?.location = location
                }
              }
            }
          } catch let err {
            fatalError(err.localizedDescription)
          }
        }
      }
    }, completionHandler: { _ in
      DispatchQueue.main.async {
        completion?()
      }
    })
  }

  func flash(_ mode: AVCaptureFlashMode) {
    guard let device = currentInput?.device , device.isFlashModeSupported(mode) else { return }

    queue.async {
      self.lock {
        device.flashMode = mode
      }
    }
  }

  func focus(_ point: CGPoint) {
    guard let device = currentInput?.device , device.isFocusModeSupported(AVCaptureFocusMode.locked) else { return }

    queue.async {
      self.lock {
        device.focusPointOfInterest = point
      }
    }
  }

  // MARK: - Lock

  func lock(_ block: () -> Void) {
    if let device = currentInput?.device , (try? device.lockForConfiguration()) != nil {
      block()
      device.unlockForConfiguration()
    }
  }

  // MARK: - Configure
  func configure(_ block: () -> Void) {
    session.beginConfiguration()
    block()
    session.commitConfiguration()
  }

  // MARK: - Preset

  func configurePreset(_ input: AVCaptureDeviceInput) {

    if ImagePickerController.isCompressQuality {
      if input.device.supportsAVCaptureSessionPreset(AVCaptureSessionPresetHigh) && self.session.canSetSessionPreset(AVCaptureSessionPresetHigh) {
        self.session.sessionPreset = AVCaptureSessionPresetHigh
        return
      }
    }
    for asset in preferredPresets() {
      if input.device.supportsAVCaptureSessionPreset(asset) && self.session.canSetSessionPreset(asset) {
        self.session.sessionPreset = asset
        return
      }
    }
  }

  func preferredPresets() -> [String] {
    return [
      AVCaptureSessionPresetPhoto,
      AVCaptureSessionPresetHigh,
      AVCaptureSessionPresetMedium,
      AVCaptureSessionPresetLow
    ]
  }
}
