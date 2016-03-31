import Photos

public struct ImagePicker {

  public static func fetch(completion: (assets: [PHAsset]) -> Void) {
    guard PHPhotoLibrary.authorizationStatus() == .Authorized else { return }
    
    var assets = [PHAsset]()
    let fetchResult = PHAsset.fetchAssetsWithMediaType(.Image, options: PHFetchOptions())
    fetchResult.enumerateObjectsUsingBlock { object, index, stop in
      if let asset = object as? PHAsset {
        assets.insert(asset, atIndex: 0)
      }
    }
    
    dispatch_async(dispatch_get_main_queue(), {
      completion(assets: assets)
    })
  }

  public static func resolveAsset(asset: PHAsset, size: CGSize = CGSize(width: 720, height: 1280), completion: (image: UIImage?) -> Void) {
    let imageManager = PHImageManager.defaultManager()
    let requestOptions = PHImageRequestOptions()

    imageManager.requestImageForAsset(asset, targetSize: size, contentMode: .AspectFill, options: requestOptions) { image, info in
      if let info = info where info["PHImageFileUTIKey"] == nil {
        dispatch_async(dispatch_get_main_queue(), {
          completion(image: image)
        })
      }
    }
  }

  public static func resolveAssets(assets: [PHAsset], size: CGSize = CGSize(width: 720, height: 1280)) -> [UIImage] {
    let imageManager = PHImageManager.defaultManager()
    let requestOptions = PHImageRequestOptions()
    requestOptions.synchronous = true

    var images = [UIImage]()
    for asset in assets {
      imageManager.requestImageForAsset(asset, targetSize: size, contentMode: .AspectFill, options: requestOptions) { image, info in
        if let image = image {
          images.append(image)
        }
      }
    }
    
    return images
  }
}
