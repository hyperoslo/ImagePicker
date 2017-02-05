import UIKit
import AVFoundation

struct Helper {

  private(set) static var previousOrientation = UIDeviceOrientation.unknown

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

  static func rotationTransform() -> CGAffineTransform {
    let currentOrientation = UIDevice.current.orientation
    var result: CGAffineTransform

    switch Configuration.lockedOrientation {
    case UIInterfaceOrientationMask.allButUpsideDown:
      if currentOrientation == .portraitUpsideDown {
        result = getTransform(fromDeviceOrientation: previousOrientation)
      } else {
        result = getTransform(fromDeviceOrientation: currentOrientation)
        previousOrientation = currentOrientation
      }
    case UIInterfaceOrientationMask.landscape:
      if currentOrientation == .landscapeRight || (!currentOrientation.isLandscape && previousOrientation == .landscapeRight) {
        result = getTransform(fromDeviceOrientation: .landscapeRight)
        previousOrientation = .landscapeRight
      } else {
        result = getTransform(fromDeviceOrientation: .landscapeLeft)
        previousOrientation = .landscapeLeft
      }
    case UIInterfaceOrientationMask.landscapeLeft:
      result = getTransform(fromDeviceOrientation: .landscapeLeft)
      previousOrientation = .landscapeLeft
    case UIInterfaceOrientationMask.landscapeRight:
      result = getTransform(fromDeviceOrientation: .landscapeRight)
      previousOrientation = .landscapeRight
    case UIInterfaceOrientationMask.portraitUpsideDown:
      result = getTransform(fromDeviceOrientation: .portraitUpsideDown)
      previousOrientation = .portraitUpsideDown
    case UIInterfaceOrientationMask.portrait:
      result = getTransform(fromDeviceOrientation: .portrait)
      previousOrientation = .portrait
    default:
      result = getTransform(fromDeviceOrientation: currentOrientation)
      previousOrientation = currentOrientation
    }

    return result
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
    var result: AVCaptureVideoOrientation
    let currentOrientation = UIDevice.current.orientation

    switch Configuration.lockedOrientation {
    case UIInterfaceOrientationMask.allButUpsideDown:
      if currentOrientation == .portraitUpsideDown {
        result = getVideoOrientation(fromDeviceOrientation: previousOrientation)
      } else {
        result = getVideoOrientation(fromDeviceOrientation: currentOrientation)
      }
    case UIInterfaceOrientationMask.landscape:
      if currentOrientation == .landscapeRight || (!currentOrientation.isLandscape && previousOrientation == .landscapeRight) {
        result = getVideoOrientation(fromDeviceOrientation: .landscapeRight)
      } else {
        result = getVideoOrientation(fromDeviceOrientation: .landscapeLeft)
      }
    case UIInterfaceOrientationMask.landscapeLeft:
      result = getVideoOrientation(fromDeviceOrientation: .landscapeLeft)
    case UIInterfaceOrientationMask.landscapeRight:
      result = getVideoOrientation(fromDeviceOrientation: .landscapeRight)
    case UIInterfaceOrientationMask.portraitUpsideDown:
      result = getVideoOrientation(fromDeviceOrientation: .portraitUpsideDown)
    case UIInterfaceOrientationMask.portrait:
      result = getVideoOrientation(fromDeviceOrientation: .portrait)
    default:
      result = getVideoOrientation(fromDeviceOrientation: currentOrientation)
    }

    return result
  }

}
