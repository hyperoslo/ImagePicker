import UIKit

class ImageStack: UIView {

  static let sharedStack = ImageStack()

  var images: NSMutableArray = NSMutableArray()
  var views: NSMutableArray = NSMutableArray()

  override init(frame: CGRect) {
    super.init(frame: frame)

  }

  func pushImage(image: UIImage) {
    images.insertObject(image, atIndex: 0)
    println("Image pushed")
    println(images)
  }

  func dropImage(image: UIImage) {
    images.removeObject(image)
    println("Image dropped")
    println(images)
  }

  func containsImage(image: UIImage) -> Bool {
    return images.containsObject(image)
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
