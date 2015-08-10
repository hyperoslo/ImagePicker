import UIKit

class ImageStack: UIView {

  override init(frame: CGRect) {
    super.init(frame: frame)

  }

  func pushImage(image: UIImage) {
    println("Image pushed")
  }

  func dropImage(image: UIImage) {
    println("Image dropped")
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
