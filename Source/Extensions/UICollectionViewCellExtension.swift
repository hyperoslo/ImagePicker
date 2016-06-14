//
//  UICollectionViewCellExtension.swift
//  ImagePicker
//
//  Created by Diogo Antunes on 6/14/16.
//  Copyright © 2016 Hyper Interaktiv AS. All rights reserved.
//

import UIKit

protocol ReusableView { }

extension ReusableView where Self: UIView {
  
  static var reuseIdentifier: String {
    return String(self)
  }
}

extension UICollectionViewCell: ReusableView { }