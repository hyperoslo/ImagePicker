import UIKit
import Photos

public class ImageStack {

  public struct Notifications {
    public static let imageDidPush = "imageDidPush"
    public static let imageDidDrop = "imageDidDrop"
    public static let stackDidReload = "stackDidReload"
  }

  public var assets = [PHAsset]()
  private let imageKey = "image"

  public func pushAsset(_ asset: PHAsset) {
    assets.append(asset)
    NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.imageDidPush), object: self, userInfo: [imageKey: asset])
  }

  public func dropAsset(_ asset: PHAsset) {
    assets = assets.filter() {$0 != asset}
    NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.imageDidDrop), object: self, userInfo: [imageKey: asset])
  }

  public func resetAssets(_ assetsArray: [PHAsset]) {
    assets = assetsArray
    NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.stackDidReload), object: self, userInfo: nil)
  }

  public func containsAsset(_ asset: PHAsset) -> Bool {
    return assets.contains(asset)
  }
}
