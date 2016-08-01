import UIKit

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
}
