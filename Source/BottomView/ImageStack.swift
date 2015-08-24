import UIKit

struct ImageStack {

  let imageDidPushNotification = "imageDidPush:"
  let imageDidDropNotification = "imageDidDrop:"
  let imageKey = "image"

  static var sharedStack = ImageStack()

  var images: [UIImage] = [UIImage]()

  mutating func pushImage(image: UIImage) {
    images.append(image)
    NSNotificationCenter.defaultCenter().postNotificationName(imageDidPushNotification, object: nil, userInfo: ["image" : image])
  }

  mutating func dropImage(image: UIImage) {
    images = images.filter() {$0 != image}
    NSNotificationCenter.defaultCenter().postNotificationName(imageDidDropNotification, object: nil, userInfo: ["image" : image])
  }

  func containsImage(image: UIImage) -> Bool {
    return contains(images, image)
  }
}
