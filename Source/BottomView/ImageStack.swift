import UIKit
import Photos

open class ImageStack {

  open var assets = [PHAsset]()
  fileprivate let imageKey = "image"

  open func pushAsset(_ asset: PHAsset) {
    assets.append(asset)
    NotificationCenter.post(notification: .imageDidPush, object: self, userInfo: [imageKey: asset])
  }

  open func dropAsset(_ asset: PHAsset) {
    assets = assets.filter() {$0 != asset}
    NotificationCenter.post(notification: .imageDidDrop, object: self, userInfo: [imageKey: asset])
  }

  open func resetAssets(_ assetsArray: [PHAsset]) {
    assets = assetsArray
    NotificationCenter.post(notification: .stackDidReload, object: self)
  }

  open func containsAsset(_ asset: PHAsset) -> Bool {
    return assets.contains(asset)
  }
}
