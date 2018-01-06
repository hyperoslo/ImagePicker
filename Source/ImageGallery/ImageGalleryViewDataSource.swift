import UIKit

extension ImageGalleryView: UICollectionViewDataSource {

  struct CollectionView {
    static let reusableIdentifier = "imagesReusableIdentifier"
  }

  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    displayNoImagesMessage(assets.isEmpty)
    return assets.count
  }

  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionView.reusableIdentifier,
      for: indexPath) as? ImageGalleryViewCell else { return UICollectionViewCell() }

    let asset = assets[(indexPath as NSIndexPath).row]

    AssetManager.resolveAsset(asset, size: CGSize(width: 160, height: 240), shouldPreferLowRes: configuration.useLowResolutionPreviewImage) { image in
      if let image = image {
        cell.configureCell(image)

        if (indexPath as NSIndexPath).row == 0 && self.shouldTransform {
          cell.transform = CGAffineTransform(scaleX: 0, y: 0)

          UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions(), animations: {
            cell.transform = CGAffineTransform.identity
            }) { _ in }

          self.shouldTransform = false
        }

        if self.selectedStack.containsAsset(asset) {
          cell.selectedImageView.image = AssetManager.getImage("selectedImageGallery")
          cell.selectedImageView.alpha = 1
          cell.selectedImageView.transform = CGAffineTransform.identity
        } else {
          cell.selectedImageView.image = nil
        }
        cell.duration = asset.duration
      }
    }

    return cell
  }
}
