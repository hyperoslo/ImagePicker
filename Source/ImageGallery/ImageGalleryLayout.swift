import UIKit

class ImageGalleryLayout: UICollectionViewFlowLayout {

  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    guard let attributes = super.layoutAttributesForElements(in: rect) else {
      return super.layoutAttributesForElements(in: rect)
    }
    
    var newAttributes = [UICollectionViewLayoutAttributes]()
    for attribute in attributes {
      let n = attribute.copy() as! UICollectionViewLayoutAttributes
      n.transform = Helper.rotationTransform()
      newAttributes.append(n)
    }
    
    return newAttributes
  }
}
