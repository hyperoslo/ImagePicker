import Foundation
import AudioToolbox

enum SoundEffect: Int {
  case cameraShutter = 1108
  
  func play() {
     AudioServicesPlaySystemSound(SystemSoundID(self.rawValue))
  }
}
