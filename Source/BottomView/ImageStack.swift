import UIKit

public class ImageStack {

  public struct Notifications {
    public static let imageDidPushNotification = "imageDidPush:"
    public static let imageDidDropNotification = "imageDidDrop:"
    public static let stackDidReload = "stackDidReload:"
    public static let imageKey = "image"
  }

  public var images: [UIImage] = [UIImage]()

  public func pushImage(image: UIImage) {
    images.append(image)
    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.imageDidPushNotification, object: self, userInfo: ["image" : image])
  }

  public func dropImage(image: UIImage) {
    images = images.filter() {$0 != image}
    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.imageDidDropNotification, object: self, userInfo: ["image" : image])
  }

  public func resetImages(newImages: [UIImage]) {
    images = newImages
    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.stackDidReload, object: self, userInfo: nil)
  }

  public func containsImage(image: UIImage) -> Bool {
    return contains(images, image)
  }
}