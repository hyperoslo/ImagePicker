import Foundation
import UIKit
import Photos
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


open class AssetManager {

  open static func getImage(_ name: String) -> UIImage {
    let traitCollection = UITraitCollection(displayScale: 3)
    var bundle = Bundle(for: AssetManager.self)

    bundle = Bundle(path: "\((bundle.resourcePath)!)/ImagePicker.bundle")!

    return UIImage(named: name, in: bundle, compatibleWith: traitCollection) ?? UIImage()
  }

  open static func fetch(_ completion: @escaping (_ assets: [PHAsset]) -> Void) {
    let fetchOptions = PHFetchOptions()
    let authorizationStatus = PHPhotoLibrary.authorizationStatus()
    var fetchResult: PHFetchResult<PHAsset>?

    guard authorizationStatus == .authorized else { return }

    if fetchResult == nil {
      fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
    }

    if fetchResult?.count > 0 {
      var assets = [PHAsset]()
      //
      //        collections.enumerateObjects({ (object, index, stop) in
      //            collection as! PHAssetCollection
      //            let assets = PHAsset.fetchAssets(in: collection, options: nil)
      //            assets.enumerateObjects({ (object, count, stop) in
      //                content.append(object)
      //            })
      //
      //        })

      fetchResult?.enumerateObjects( { (object, index, stop) in
        assets.insert(object, at: 0)
      })

      DispatchQueue.main.async(execute: {
        completion(assets)
      })
    }
  }

  open static func resolveAsset(_ asset: PHAsset, size: CGSize = CGSize(width: 720, height: 1280), completion: @escaping (_ image: UIImage?) -> Void) {
    let imageManager = PHImageManager.default()
    let requestOptions = PHImageRequestOptions()

    imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, info in
      if let info = info , info["PHImageFileUTIKey"] == nil {
        DispatchQueue.main.async(execute: {
          completion(image)
        })
      }
    }
  }

  open static func resolveAssets(_ assets: [PHAsset],imagesClosers: @escaping ([(imageData: Data, location: CLLocation?)])->()) {
    let imageManager = PHImageManager.default()
    let requestOptions = PHImageRequestOptions()
    requestOptions.isSynchronous = true

    var imagesData = [(imageData: Data,location: CLLocation?)]()

    for asset in assets {
      let options = PHContentEditingInputRequestOptions()
      options.isNetworkAccessAllowed = true
      asset.requestContentEditingInput(with: options) { (contentEditingInput: PHContentEditingInput?, _) -> Void in

        let optionsRequest = PHImageRequestOptions()
        optionsRequest.version = .original
        optionsRequest.isSynchronous = true
        imageManager.requestImageData(for: asset, options: optionsRequest, resultHandler: { (data, string, orientation, info) in
          if let data = data {
            imagesData.append((data, contentEditingInput!.location))
            if (imagesData.count == assets.count) {
              imagesClosers(imagesData)
            }
          }
        })
      }
    }
  }

}
