import UIKit

public class ImageStack {

  public struct Notifications {
    public static let imageDidPush = "imageDidPush"
    public static let imageDidDrop = "imageDidDrop"
    public static let stackDidReload = "stackDidReload"
    public static let imageKey = "image"
  }

  public var images = [UIImage]()

  public func pushImage(image: UIImage) {
    images.append(image)
    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.imageDidPush, object: self, userInfo: ["image" : image])
  }

  public func dropImage(image: UIImage) {
    images = images.filter() {$0 != image}
    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.imageDidDrop, object: self, userInfo: ["image" : image])
  }

  public func resetImages(newImages: [UIImage]) {
    images = newImages
    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.stackDidReload, object: self, userInfo: nil)
  }

  public func containsImage(image: UIImage) -> Bool {
    return contains(images, image)
  }
}
