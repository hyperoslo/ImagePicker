import UIKit

class ImageGalleryLayout: UICollectionViewFlowLayout {

  override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    let attributes = super.layoutAttributesForElementsInRect(rect)
    
    attributes?.forEach {
      $0.transform = Helper.rotationTransform()
    }

    return attributes
  }
}
