//
//  SoundEffect.swift
//  ImagePicker
//
//  Created by Zachary Steed on 9/1/17.
//  Copyright © 2017 Hyper Interaktiv AS. All rights reserved.
//

import Foundation
import AudioToolbox

enum SoundEffect: Int {
  case cameraShutter = 1108
  
  func play() {
     AudioServicesPlaySystemSound(SystemSoundID(self.rawValue))
  }
}
