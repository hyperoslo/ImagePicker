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

extension NotificationCenter {
  enum Notifications: String {
    case imageDidPush
    case imageDidDrop
    case stackDidReload
  }

  class func post(notification: Notifications, object: Any?, userInfo: [AnyHashable : Any]? = .none) {
    NotificationCenter.default.post(name: Notification.Name(rawValue: notification.rawValue), object: object, userInfo: userInfo)
  }
  
  class func addObserver(_ observer: AnyObject, selector: Selector, notification: Notifications, object: AnyObject? = .none) {
    NotificationCenter.default.addObserver(observer, selector: selector, name: Notification.Name(rawValue: notification.rawValue), object: object)
  }
}
