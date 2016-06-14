//
//  IntExtension.swift
//  ImagePicker
//
//  Created by Diogo Antunes on 6/14/16.
//  Copyright © 2016 Hyper Interaktiv AS. All rights reserved.
//

import Foundation

extension Int {
  
  func times(repeatFunction: () -> ()) {
    if self > 0 {
      for _ in 0..<self {
        repeatFunction()
      }
    }
  }
}
