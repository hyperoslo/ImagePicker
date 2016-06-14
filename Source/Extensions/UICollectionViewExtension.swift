//
//  UICollectionViewExtension.swift
//  ImagePicker
//
//  Created by Diogo Antunes on 6/14/16.
//  Copyright © 2016 Hyper Interaktiv AS. All rights reserved.
//

import UIKit

extension UICollectionView {
    
  func register<T: UICollectionViewCell where T: ReusableView>(_: T.Type) {
    registerClass(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
  }

  
  func dequeueReusableCell<T: UICollectionViewCell where T: ReusableView>(forIndexPath indexPath: NSIndexPath) -> T {
    guard let cell = dequeueReusableCellWithReuseIdentifier(T.reuseIdentifier, forIndexPath: indexPath) as? T
      else { fatalError("Could not dequeue reusable cell with identifier: \(T.reuseIdentifier)") }
    
    return cell
  }
  
}