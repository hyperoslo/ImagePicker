import Foundation
import UIKit
import Photos

open class AssetManager {

  public static func getImage(_ name: String) -> UIImage {
    let traitCollection = UITraitCollection(displayScale: 3)
    var bundle = Bundle(for: AssetManager.self)

    if let resource = bundle.resourcePath, let resourceBundle = Bundle(path: resource + "/ImagePicker.bundle") {
      bundle = resourceBundle
    }

    return UIImage(named: name, in: bundle, compatibleWith: traitCollection) ?? UIImage()
  }

  public static func fetch(withConfiguration configuration: Configuration, _ completion: @escaping (_ assets: [IPAsset]) -> Void) {
    guard PHPhotoLibrary.authorizationStatus() == .authorized else { return }

    DispatchQueue.global(qos: .background).async {
      let fetchResult = configuration.allowVideoSelection
        ? PHAsset.fetchAssets(with: PHFetchOptions())
        : PHAsset.fetchAssets(with: .image, options: PHFetchOptions())

      if fetchResult.count > 0 {
        var assets = [IPAsset]()
        fetchResult.enumerateObjects({ object, _, _ in
            let asset = IPAsset()
            asset.phAsset = object
            assets.insert(asset, at: 0)
        })

        DispatchQueue.main.async {
          completion(assets)
        }
      }
    }
  }

  public static func resolveAsset(_ asset: IPAsset, size: CGSize = CGSize(width: 720, height: 1280), completion: @escaping (_ image: IPAsset?) -> Void) {
    let imageManager = PHImageManager.default()
    let requestOptions = PHImageRequestOptions()
    requestOptions.deliveryMode = .highQualityFormat
    requestOptions.isNetworkAccessAllowed = true

    if let phAsset = asset.phAsset, asset.thumbnailImage == nil{
        imageManager.requestImage(for: phAsset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, info in
          if let info = info, info["PHImageFileUTIKey"] == nil {
            DispatchQueue.main.async(execute: {
                asset.thumbnailImage = image
                completion(asset)
            })
          }
        }
    } else if let image = asset.image, asset.thumbnailImage == nil {
        asset.thumbnailImage = resizeImage(image: image, targetSize: size)
        completion(asset)
    } else {
        completion(asset)
    }
    
    
  }

  public static func resolveAssets(_ assets: [IPAsset], size: CGSize = CGSize(width: 720, height: 1280)) -> [IPAsset] {
    let imageManager = PHImageManager.default()
    let requestOptions = PHImageRequestOptions()
    requestOptions.isSynchronous = true

    for asset in assets {
        if let phAsset = asset.phAsset{
            imageManager.requestImage(for: phAsset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, _ in
                if let image = image {
                    asset.image = image
                }
            }
        }
    }
    return assets
  }
  
  
  public static func resolveAssets(_ assets: [IPAsset], size: CGSize = CGSize(width: 720, height: 1280), completion: @escaping (_ image: [IPAsset]) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
      let imageManager = PHImageManager.default()
      let requestOptions = PHImageRequestOptions()
      requestOptions.isSynchronous = true
      requestOptions.isNetworkAccessAllowed = true
      
      for asset in assets {
        if let phAsset = asset.phAsset{
            imageManager.requestImage(for: phAsset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, _ in
                if let image = image {
                    asset.image = image
                }
            }
        }
      }
      
      DispatchQueue.main.async {
        completion(assets)
      }
    }
  }
    
    private static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
