import UIKit

class ImageStack {

  struct Notifications {
    static let imageDidPushNotification = "imageDidPush:"
    static let imageDidDropNotification = "imageDidDrop:"
    static let imageKey = "image"
  }

  var images: [UIImage] = [UIImage]()

   func pushImage(image: UIImage) {
    images.append(image)
    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.imageDidPushNotification, object: self, userInfo: ["image" : image])
  }

   func dropImage(image: UIImage) {
    images = images.filter() {$0 != image}
    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.imageDidDropNotification, object: self, userInfo: ["image" : image])
  }

  func containsImage(image: UIImage) -> Bool {
    return contains(images, image)
  }
}
