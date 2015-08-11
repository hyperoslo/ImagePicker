import UIKit

protocol ImageStackDelegate {
   func imageStackDidReload()
}

struct ImageStack {

  static var sharedStack = ImageStack()

  var images: [UIImage] = [UIImage]()
  var delegate: ImageStackDelegate?

  mutating func pushImage(image: UIImage) {
    images.append(image)
    delegate?.imageStackDidReload()
    println("Image pushed")
    println(images)
  }

  mutating func dropImage(image: UIImage) {
    images = images.filter() {$0 != image}
    delegate?.imageStackDidReload()
    println("Image dropped")
    println(images)
  }

  func containsImage(image: UIImage) -> Bool {
    return contains(images, image)
  }
}