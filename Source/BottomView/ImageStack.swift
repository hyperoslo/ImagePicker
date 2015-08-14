import UIKit

protocol ImageStackDelegate {
  func imageDidPush(image: UIImage)
  func imageStackDidDrop(image: UIImage)
}

struct ImageStack {

  static var sharedStack = ImageStack()

  var images: [UIImage] = [UIImage]()
  var delegate: ImageStackDelegate?

  mutating func pushImage(image: UIImage) {
    images.append(image)
    delegate?.imageDidPush(image)
  }

  mutating func dropImage(image: UIImage) {
    images = images.filter() {$0 != image}
    delegate?.imageStackDidDrop(image)
  }

  func containsImage(image: UIImage) -> Bool {
    return contains(images, image)
  }
}
