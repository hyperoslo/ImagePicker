import UIKit
import AVFoundation

struct Helper {

  static func rotationTransform() -> CGAffineTransform {
    switch UIDevice.currentDevice().orientation {
    case .LandscapeLeft:
      return CGAffineTransformMakeRotation(CGFloat(M_PI_2))
    case .LandscapeRight:
      return CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
    case .PortraitUpsideDown:
      return CGAffineTransformMakeRotation(CGFloat(M_PI))
    default:
      return CGAffineTransformIdentity
    }
  }

  static func videoOrientation() -> AVCaptureVideoOrientation {
    switch UIDevice.currentDevice().orientation {
    case .Portrait: return .Portrait
    case .LandscapeLeft: return .LandscapeRight
    case .LandscapeRight: return .LandscapeLeft
    case .PortraitUpsideDown: return .PortraitUpsideDown
    default: return .Portrait
    }
  }
}
