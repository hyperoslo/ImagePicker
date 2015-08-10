import UIKit

class ImageStack: UIView {

  var images: NSMutableArray = NSMutableArray()

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

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
