import Photos
import AssetsLibrary

struct Photos {

  static func fetch(completion: (assets: [PHAsset]) -> Void) {
    let fetchOptions = PHFetchOptions()
    let authorizationStatus = ALAssetsLibrary.authorizationStatus()
    var fetchResult: PHFetchResult?

    guard authorizationStatus == .Authorized else { return }

    if fetchResult == nil {
      fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions)
    }

    if fetchResult?.count > 0 {
      var assets = [PHAsset]()
      fetchResult?.enumerateObjectsUsingBlock { object, index, stop in
        if let asset = object as? PHAsset {
          assets.append(asset)
        }
      }

      dispatch_async(dispatch_get_main_queue(), {
        completion(assets: assets)
      })
    }
  }
}
