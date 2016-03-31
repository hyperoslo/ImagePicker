import Foundation
import UIKit

public class AssetManager {
  
  public static func getImage(name: String) -> UIImage {
    let traitCollection = UITraitCollection(displayScale: 3)
    var bundle = NSBundle(forClass: AssetManager.self)
    
    if let bundlePath = bundle.resourcePath?.stringByAppendingString("/ImagePicker.bundle"), resourceBundle = NSBundle(path: bundlePath) {
      bundle = resourceBundle
    }
    
    return UIImage(named: name, inBundle: bundle, compatibleWithTraitCollection: traitCollection) ?? UIImage()
  }
}