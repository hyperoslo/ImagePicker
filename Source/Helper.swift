import UIKit
import AVFoundation

struct Helper {
  
  static var previousOrientation = UIDeviceOrientation.unknown
  
  static func rotationTransform() -> CGAffineTransform {
    switch UIApplication.shared.statusBarOrientation {
    case .landscapeLeft:
      return CGAffineTransform(rotationAngle: CGFloat.pi * 2.0)
    case .landscapeRight:
      return CGAffineTransform(rotationAngle: -(CGFloat.pi * 2.0))
    case .portraitUpsideDown:
      return CGAffineTransform(rotationAngle: CGFloat.pi)
    default:
      return CGAffineTransform.identity
    }
  }
  
  static func setOrientation() {
    let currentOrientation = UIDevice.current.orientation
    switch currentOrientation {
    case .portrait, .portraitUpsideDown, .landscapeLeft, .landscapeRight:
      previousOrientation = currentOrientation
    default:
      break
    }
    
    if previousOrientation == .unknown {
      previousOrientation = .portrait
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
    case .portrait:
      return .portrait
    default:
      if previousOrientation == .unknown {
        return .portrait
      } else {
        return getVideoOrientation(fromDeviceOrientation: previousOrientation)
      }
    }
  }

  static func videoOrientation() -> AVCaptureVideoOrientation {
    switch UIApplication.shared.statusBarOrientation {
    case .portrait: return .portrait
    case .landscapeLeft: return .landscapeLeft
    case .landscapeRight: return .landscapeRight
    case .portraitUpsideDown: return .portraitUpsideDown
    default: return .portrait
    }
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
