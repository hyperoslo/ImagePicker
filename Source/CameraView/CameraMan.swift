import Foundation
import AVFoundation
import PhotosUI

class CameraMan {

  let session = AVCaptureSession()
  let queue = dispatch_queue_create("no.hyper.ImagePicker.Camera.SessionQueue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0))
  var backCamera: AVCaptureDevice?
  var frontCamera: AVCaptureDevice?

  var noCameraHandler: (() -> Void)?

  // MARK: - Setup

  func setup() {
    
  }

  func setupDevices() {
    AVCaptureDevice
    .devices().flatMap {
      return $0 as? AVCaptureDevice
    }.filter {
      return $0.hasMediaType(AVMediaTypeVideo)
    }.forEach {
      switch $0.position {
      case .Front:
        self.frontCamera = $0
      case .Back:
        self.backCamera = $0
      default:
        break
      }
    }

  }

  // MARK: - Permission

  func checkPermission() {
    let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)

    switch  status {
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
}
