import UIKit
import Photos

open class ImageStack {

  public struct Notifications {
    public static let imageDidPush = "imageDidPush"
    public static let imageDidDrop = "imageDidDrop"
    public static let stackDidReload = "stackDidReload"
  }

  open var assets = [IPAsset]()
  fileprivate let imageKey = "image"

  open func pushAsset(_ asset: IPAsset) {
    if containsAsset(asset) {
        if asset.cameraPicture {
            asset.isSelected = true
        }
    } else {
        assets.insert(asset, at: 0)
    }
    
    NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.imageDidPush), object: self, userInfo: [imageKey: asset])
  }

  open func dropAsset(_ asset: IPAsset) {
    if asset.cameraPicture{
        asset.isSelected = false
    } else {
        assets = assets.filter {$0.phAsset != asset.phAsset}
    }
    NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.imageDidDrop), object: self, userInfo: [imageKey: asset])
  }

  open func resetAssets(_ assetsArray: [IPAsset]) {
    assets = assetsArray
    NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.stackDidReload), object: self, userInfo: nil)
  }

  open func containsAsset(_ asset: IPAsset) -> Bool {
    return assets.contains(where: { iAsset in (iAsset.phAsset != nil && iAsset.phAsset == asset.phAsset) || (iAsset.image != nil && iAsset.image == asset.image) })
  }
    
    open func countAssets() -> Int {
        if assets.isEmpty { return 0 }
        else {
            return filterSelectedAssets().count
        }
    }
    
    open func filterSelectedAssets() -> [IPAsset] {
        return assets.filter({ $0.isSelected == true || $0.cameraPicture == false })
    }
}

@objc open class IPAsset: NSObject {
    open var phAsset: PHAsset?
    open var image: UIImage?
    open var isSelected: Bool = true
    open var cameraPicture: Bool = false
    open var thumbnailImage: UIImage?
}
