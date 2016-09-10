import UIKit
import AVFoundation

struct Helper {

  static func rotationTransform() -> CGAffineTransform {
    switch UIDevice.current.orientation {
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

  static func videoOrientation() -> AVCaptureVideoOrientation {
    switch UIDevice.current.orientation {
    case .portrait: return .portrait
    case .landscapeLeft: return .landscapeRight
    case .landscapeRight: return .landscapeLeft
    case .portraitUpsideDown: return .portraitUpsideDown
    default: return .portrait
    }
  }
}
