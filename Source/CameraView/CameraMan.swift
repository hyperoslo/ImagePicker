import Foundation
import AVFoundation
import PhotosUI
import MobileCoreServices

protocol CameraManDelegate: class {
  func cameraManNotAvailable(_ cameraMan: CameraMan)
  func cameraManDidStart(_ cameraMan: CameraMan)
  func cameraMan(_ cameraMan: CameraMan, didChangeInput input: AVCaptureDeviceInput)
}

class CameraMan {
  weak var delegate: CameraManDelegate?

  let session = AVCaptureSession()
  let queue = DispatchQueue(label: "no.hyper.ImagePicker.Camera.SessionQueue")

  var backCamera: AVCaptureDeviceInput?
  var frontCamera: AVCaptureDeviceInput?
  var stillImageOutput: AVCaptureStillImageOutput?
  var startOnFrontCamera: Bool = false
  var photoQuality: AVCaptureSession.Preset = .photo

  deinit {
    stop()
  }

  // MARK: - Setup

  func setup(_ startOnFrontCamera: Bool = false, photoQuality: AVCaptureSession.Preset) {
    self.startOnFrontCamera = startOnFrontCamera
    self.photoQuality = photoQuality
    checkPermission()
  }

  func setupDevices() {
    // Input
    AVCaptureDevice
    .devices()
    .filter {
      return $0.hasMediaType(AVMediaType.video)
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
    let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)

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
    AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
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

    guard let input = (self.startOnFrontCamera) ? frontCamera ?? backCamera : backCamera, let output = stillImageOutput else { return }

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

  func takePhoto(_ previewLayer: AVCaptureVideoPreviewLayer, location: CLLocation?,
                 heading: CLHeading?, completion: (() -> Void)? = nil) {
    guard let connection = stillImageOutput?.connection(with: AVMediaType.video) else { return }

    connection.videoOrientation = Helper.videoOrientation()

    queue.async {
      self.stillImageOutput?.captureStillImageAsynchronously(from: connection) { buffer, error in
        guard let buffer = buffer, error == nil && CMSampleBufferIsValid(buffer),
          let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer) else {
            DispatchQueue.main.async {
              completion?()
            }
            return
        }

        self.savePhoto(imageData, location: location, heading: heading, completion: completion)
      }
    }
  }

  func savePhoto(_ image: UIImage, location: CLLocation?, completion: (() -> Void)? = nil) {
    PHPhotoLibrary.shared().performChanges({
      let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
      request.creationDate = Date()
      request.location = location
      }, completionHandler: { (_, _) in
        DispatchQueue.main.async {
          completion?()
        }
    })
  }

  private func attachEXIF(to image: Data, exif: [String: Any]) -> Data? {
    if
    let imageDataProvider = CGDataProvider(data: image as CFData),
    let imageRef = CGImage(jpegDataProviderSource: imageDataProvider, decode: nil, shouldInterpolate: true, intent: .defaultIntent),
    let newImageData = CFDataCreateMutable(nil, 0),
    let type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, "image/jpeg" as CFString, kUTTypeImage),
    let destination = CGImageDestinationCreateWithData(newImageData, type.takeRetainedValue(), 1, nil) {

      CGImageDestinationAddImage(destination, imageRef, exif as CFDictionary)
      CGImageDestinationFinalize(destination)
      return newImageData as Data
    }
    return nil
  }

  private func getGPSDictionary(for location: CLLocation, and heading: CLHeading?) -> [String: Any] {
    var dictionary = [String: Any]()

    // Time and date must be provided as strings, not as an Date object
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss.SSSSSS"
    dictionary[kCGImagePropertyGPSTimeStamp as String] = formatter.string(from: location.timestamp)
    formatter.dateFormat = "yyyy:MM:dd"
    dictionary[kCGImagePropertyGPSDateStamp as String] = formatter.string(from: location.timestamp)

    // Latitude
    let latitude = location.coordinate.latitude
    dictionary[kCGImagePropertyGPSLatitudeRef as String] = (latitude < 0) ? "S" : "N"
    dictionary[kCGImagePropertyGPSLatitude as String] = fabs(latitude)

    // Longitude
    let longitude = location.coordinate.longitude
    dictionary[kCGImagePropertyGPSLongitudeRef as String] = (longitude < 0) ? "W" : "E"
    dictionary[kCGImagePropertyGPSLongitude as String] = fabs(longitude)

    // Degree of Precision
    dictionary[kCGImagePropertyGPSDOP as String] = location.horizontalAccuracy

    // Altitude
    let altitude = location.altitude
    if !altitude.isNaN {
      dictionary[kCGImagePropertyGPSAltitudeRef as String] = altitude < 0 ? 1 : 0
      dictionary[kCGImagePropertyGPSAltitude as String] = fabs(altitude)
    }

    // Speed, must be converted from m/s to km/h
    if location.speed >= 0 {
      dictionary[kCGImagePropertyGPSSpeedRef as String] = "K"
      dictionary[kCGImagePropertyGPSSpeed as String] = location.speed * (3600.0 / 1000.0)
    }

    // Direction of movement
    if location.course >= 0 {
      dictionary[kCGImagePropertyGPSTrackRef as String] = "T"
      dictionary[kCGImagePropertyGPSTrack as String] = location.course
    }

    // Direction the device is pointing
    if let heading = heading, heading.headingAccuracy >= 0.0 {
      if heading.trueHeading >= 0.0 {
        dictionary[kCGImagePropertyGPSImgDirectionRef as String] = "T"
        dictionary[kCGImagePropertyGPSImgDirection as String] = heading.trueHeading
      } else {
        // Only magnetic heading is available
        dictionary[kCGImagePropertyGPSImgDirectionRef as String] = "M"
        dictionary[kCGImagePropertyGPSImgDirection as String] = heading.magneticHeading
      }
    }

    return dictionary
  }

  func savePhoto(_ image: Data, location: CLLocation?, heading: CLHeading?, completion: (() -> Void)? = nil) {

    func complite() {
      DispatchQueue.main.async {
        completion?()
      }
    }

    let path = NSTemporaryDirectory() + "file-\(arc4random()).jpg"
    let url = URL(fileURLWithPath: path)
    guard let imageSource = CGImageSourceCreateWithData(image as CFData, nil) else {
      complite()
      return
    }
    guard var properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
     complite()
     return
    }
    if let location = location {
        properties[kCGImagePropertyGPSDictionary as String] = self.getGPSDictionary(for: location, and: heading)
    }
    guard let data = self.attachEXIF(to: image, exif: properties) else {
      complite()
      return
    }

    PHPhotoLibrary.shared().performChanges({
      let request: PHAssetChangeRequest?
      do {
        try data.write(to: url)
        request = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
      } catch {
        request = UIImage(data: image).flatMap {
          PHAssetChangeRequest.creationRequestForAsset(from: $0)
        }
      }

      guard let _request = request else {
        complite()
        return
      }

      _request.creationDate = Date()
      _request.location = location
    }, completionHandler: { (_, _) in
      complite()
    })
  }

  func flash(_ mode: AVCaptureDevice.FlashMode) {
    guard let device = currentInput?.device, device.isFlashModeSupported(mode) else { return }

    queue.async {
      self.lock {
        device.flashMode = mode
      }
    }
  }

  func focus(_ point: CGPoint) {
    guard let device = currentInput?.device, device.isFocusModeSupported(AVCaptureDevice.FocusMode.locked) else { return }

    queue.async {
      self.lock {
        device.focusPointOfInterest = point
      }
    }
  }

  func zoom(_ zoomFactor: CGFloat) {
    guard let device = currentInput?.device, device.position == .back else { return }

    queue.async {
      self.lock {
        device.videoZoomFactor = zoomFactor
      }
    }
  }

  // MARK: - Lock

  func lock(_ block: () -> Void) {
    if let device = currentInput?.device, (try? device.lockForConfiguration()) != nil {
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
    for asset in preferredPresets() {
      if input.device.supportsSessionPreset(AVCaptureSession.Preset(rawValue: asset)) && self.session.canSetSessionPreset(AVCaptureSession.Preset(rawValue: asset)) {
        self.session.sessionPreset = AVCaptureSession.Preset(rawValue: asset)
        return
      }
    }
  }

  func preferredPresets() -> [String] {
    return [
      self.photoQuality.rawValue,
      AVCaptureSession.Preset.high.rawValue,
      AVCaptureSession.Preset.low.rawValue
    ]
  }
}
