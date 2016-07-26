import UIKit

class ImageGalleryLayout: UICollectionViewFlowLayout {

  override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    let attributes = super.layoutAttributesForElementsInRect(rect)

    let rotate: CGAffineTransform

    switch UIDevice.currentDevice().orientation {
    case .LandscapeLeft:
      rotate = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
    case .LandscapeRight:
      rotate = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
    case .PortraitUpsideDown:
      rotate = CGAffineTransformMakeRotation(CGFloat(M_PI))
    default:
      rotate = CGAffineTransformIdentity
    }

    attributes?.forEach {
      $0.transform = rotate
    }

    return attributes
  }
}
