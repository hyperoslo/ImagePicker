import UIKit
import Photos

public class ImageStack {

  public struct Notifications {
    public static let imageDidPush = "imageDidPush"
    public static let imageDidDrop = "imageDidDrop"
    public static let stackDidReload = "stackDidReload"
    public static let imageKey = "image"
  }

  public var assets = [PHAsset]()

  public func pushAsset(asset: PHAsset) {
    assets.append(asset)
    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.imageDidPush, object: self, userInfo: ["image" : asset])
  }

  public func dropAsset(asset: PHAsset) {
    assets = assets.filter() {$0 != asset}
    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.imageDidDrop, object: self, userInfo: ["image" : asset])
  }

  public func resetAssets(assetsArray: [PHAsset]) {
    assets = assetsArray
    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.stackDidReload, object: self, userInfo: nil)
  }

  public func containsAsset(asset: PHAsset) -> Bool {
    return assets.contains(asset)
  }
}
