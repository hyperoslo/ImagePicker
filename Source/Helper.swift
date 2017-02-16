import UIKit
import AVFoundation

struct Helper {

  static var previousOrientation = UIDeviceOrientation.unknown

  static func getTransform(fromDeviceOrientation orientation: UIDeviceOrientation) -> CGAffineTransform {
    switch orientation {
    case .landscapeLeft:
      return CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
    case .landscapeRight:
      return CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
    case .portraitUpsideDown:
      return CGAffineTransform(rotationAngle: CGFloat(M_PI))
    default:
      return CGAffineTransform.identity
    }
  }

  static func getVideoOrientation(fromDeviceOrientation orientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
    switch orientation {
    case .landscapeLeft:
      return .landscapeRight
    case .landscapeRight:
      return .landscapeLeft
    case .portraitUpsideDown:
      return .portraitUpsideDown
    default:
      return .portrait
    }
  }

  static func videoOrientation() -> AVCaptureVideoOrientation {
    return getVideoOrientation(fromDeviceOrientation: previousOrientation)
  }

}
