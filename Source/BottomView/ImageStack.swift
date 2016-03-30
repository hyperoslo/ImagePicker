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

  public func pushAsset(asset: PHAsset) {
    assets.append(asset)
    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.imageDidPush, object: self, userInfo: [imageKey: asset])
  }

  public func dropAsset(asset: PHAsset) {
    assets = assets.filter() {$0 != asset}
    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.imageDidDrop, object: self, userInfo: [imageKey: asset])
  }

  public func resetAssets(assetsArray: [PHAsset]) {
    assets = assetsArray
    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.stackDidReload, object: self, userInfo: nil)
  }

  public func containsAsset(asset: PHAsset) -> Bool {
    return assets.contains(asset)
  }
}
