import Foundation
import UIKit
import Photos

public class AssetManager {

  public static func getImage(_ name: String) -> UIImage {
    let traitCollection = UITraitCollection(displayScale: 3)
    var bundle = Bundle(for: AssetManager.self)

  if let bundlePath = bundle.resourcePath?.appending("/ImagePicker.bundle") , let resourceBundle = Bundle(path: bundlePath) {
    bundle = resourceBundle
  }

    return UIImage(named: name, in: bundle, compatibleWith: traitCollection) ?? UIImage()
  }

  public static func fetch(_ completion: (assets: [PHAsset]) -> Void) {
    let fetchOptions = PHFetchOptions()
    let authorizationStatus = PHPhotoLibrary.authorizationStatus()
    var fetchResult: PHFetchResult<PHAsset>?

    guard authorizationStatus == .authorized else { return }

    if fetchResult == nil {
      fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions) //as? PHFetchResult<AnyObject>
    }

    if fetchResult?.count > 0 {
      var assets = [PHAsset]()
      fetchResult?.enumerateObjects({ (asset, index, stop) in
          assets.insert(asset, at: 0)
      })

      DispatchQueue.main.async(execute: {
        completion(assets: assets)
      })
    }
  }

  public static func resolveAsset(_ asset: PHAsset, size: CGSize = CGSize(width: 720, height: 1280), completion: (image: UIImage?) -> Void) {
    let imageManager = PHImageManager.default()
    let requestOptions = PHImageRequestOptions()

    imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, info in
      if let info = info , info["PHImageFileUTIKey"] == nil {
        DispatchQueue.main.async(execute: {
          completion(image: image)
        })
      }
    }
  }

  public static func resolveAssets(_ assets: [PHAsset], size: CGSize = CGSize(width: 720, height: 1280)) -> [UIImage] {
    let imageManager = PHImageManager.default()
    let requestOptions = PHImageRequestOptions()
    requestOptions.isSynchronous = true

    var images = [UIImage]()
    for asset in assets {
      imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, info in
        if let image = image {
          images.append(image)
        }
      }
    }
    
    return images
  }
}
