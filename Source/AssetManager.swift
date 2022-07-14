import Foundation
import UIKit
import Photos

extension Bundle {
    static func myResourceBundle() -> Bundle? {
        let bundles = Bundle.allBundles
        let bundlePaths = bundles.compactMap { $0.resourceURL?.appendingPathComponent("ImagePicker", isDirectory: false).appendingPathExtension("bundle") }
        
        return bundlePaths.compactMap({ Bundle(url: $0) }).first
    }
}

open class AssetManager {
    
    public static func getImage(_ name: String) -> UIImage {
        let traitCollection = UITraitCollection(displayScale: 3)
        var bundle = Bundle.myResourceBundle()
        
        if let resource = bundle?.resourcePath, let resourceBundle = Bundle(path: resource + "/ImagePicker.bundle") {
            bundle = resourceBundle
        }
        
        return UIImage(named: name, in: bundle, compatibleWith: traitCollection) ?? UIImage()
    }
    
    
    // Fetch assets from a named album
    private static func fetchFromAlbum(withConfiguration configuration: ImagePickerConfiguration,
                                      _ completion: @escaping (_ assets: [PHAsset]) -> Void) {
        
        if configuration.albumName == nil {
            fetch(withConfiguration: configuration,
                  assetCollection: nil) { albumAssets in
                completion(albumAssets)
            }
            return
        }
        
        var assets = [PHAsset]()
        
        // Title is supposed to be supported as a predicate - but isn't
        // https://www.google.com/search?client=safari&rls=en&q=phfetchoptions+predicate+title&ie=UTF-8&oe=UTF-8
        // So we fetch all, and filter ourselves.
        let result = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        
        // Now, for each matching album, fetch images
        result.enumerateObjects { assetCollection, _, stopPointer in
            if assetCollection.localizedTitle == configuration.albumName {
                // We may have multiple ioLight albums. I don't quite know how this happens; I think it's when they are
                // aded on different devices and synced by iCloud. The only reasonable thing to do is to collate them
                fetch(withConfiguration: configuration,
                      assetCollection: assetCollection) { albumAssets in
                    albumAssets.forEach { asset in
                        assets.insert(asset, at: 0)
                    }
                }
            }
        }
        
        completion(assets)
    }
    
    private static func fetch(withConfiguration configuration: ImagePickerConfiguration,
                             assetCollection: PHAssetCollection? = nil,
                             _ completion: @escaping (_ assets: [PHAsset]) -> Void) {
        let assetOptions = PHFetchOptions()
        if !configuration.allowVideoSelection {
            assetOptions.predicate = NSPredicate(format: "mediaType = \(PHAssetMediaType.image.rawValue)")
        }
        
        var fetchResult: PHFetchResult<PHAsset>!
        if let assetCollection = assetCollection {
            fetchResult = PHAsset.fetchAssets(in: assetCollection, options: assetOptions)
        } else {
            fetchResult = PHAsset.fetchAssets(with: assetOptions)
        }
        
        var assets = [PHAsset]()
        
        if fetchResult.count > 0 {
            fetchResult.enumerateObjects({ object, _, _ in
                assets.insert(object, at: 0)
            })
            
        }
        
        completion(assets)
    }
    
    // Fetch all assets
    public static func fetch(withConfiguration configuration: ImagePickerConfiguration, _ completion: @escaping (_ assets: [PHAsset]) -> Void) {
        guard PHPhotoLibrary.authorizationStatus() == .authorized else { return }
        
        DispatchQueue.global(qos: .background).async {
            fetchFromAlbum(withConfiguration: configuration) { assets in
                if !assets.isEmpty {
                    DispatchQueue.main.async {
                        completion(assets)
                    }
                }
            }
        }
    }
    
    public static func resolveAsset(_ asset: PHAsset, size: CGSize = CGSize(width: 720, height: 1280), shouldPreferLowRes: Bool = false, completion: @escaping (_ image: UIImage?) -> Void) {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = shouldPreferLowRes ? .fastFormat : .highQualityFormat
        requestOptions.isNetworkAccessAllowed = true
        
        imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, info in
            if let info = info, info["PHImageFileUTIKey"] == nil {
                DispatchQueue.main.async(execute: {
                    completion(image)
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
            imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, _ in
                if let image = image {
                    images.append(image)
                }
            }
        }
        return images
    }
}
