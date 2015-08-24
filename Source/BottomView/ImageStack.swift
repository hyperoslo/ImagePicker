import UIKit

class ImageStack {

  let imageDidPushNotification = "imageDidPush:"
  let imageDidDropNotification = "imageDidDrop:"
  let imageKey = "image"

  static var sharedStack = ImageStack()

  var images: [UIImage] = [UIImage]()

   func pushImage(image: UIImage) {
    images.append(image)
    NSNotificationCenter.defaultCenter().postNotificationName(imageDidPushNotification, object: self, userInfo: ["image" : image])
  }

   func dropImage(image: UIImage) {
    images = images.filter() {$0 != image}
    NSNotificationCenter.defaultCenter().postNotificationName(imageDidDropNotification, object: self, userInfo: ["image" : image])
  }

  func containsImage(image: UIImage) -> Bool {
    return contains(images, image)
  }
}
