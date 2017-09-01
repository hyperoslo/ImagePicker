import UIKit
import AVFoundation

struct Helper {

  static var previousOrientation = UIDeviceOrientation.unknown

  static func getTransform(fromDeviceOrientation orientation: UIDeviceOrientation) -> CGAffineTransform {
    switch orientation {
    case .landscapeLeft:
      return CGAffineTransform(rotationAngle: CGFloat.pi * 0.5)
    case .landscapeRight:
      return CGAffineTransform(rotationAngle: -(CGFloat.pi * 0.5))
    case .portraitUpsideDown:
      return CGAffineTransform(rotationAngle: CGFloat.pi)
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

  static func screenSizeForOrientation() -> CGSize {
    switch UIDevice.current.orientation {
    case .landscapeLeft, .landscapeRight:
      return CGSize(width: UIScreen.main.bounds.height,
                    height: UIScreen.main.bounds.width)
    default:
      return UIScreen.main.bounds.size
    }
  }
}
