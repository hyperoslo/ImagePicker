import UIKit

struct ImageStack {

  static let sharedStack = ImageStack()

  var images: NSMutableArray = NSMutableArray()

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
}
