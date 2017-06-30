//
//  NotificationCenter.swift
//  ImagePicker
//
//  Created by Sin Li - Work on 30/06/2017.
//  Copyright © 2017 Hyper Interaktiv AS. All rights reserved.
//

import Foundation

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
