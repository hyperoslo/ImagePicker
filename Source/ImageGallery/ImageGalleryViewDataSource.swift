import UIKit

extension ImageGalleryView: UICollectionViewDataSource {

  struct CollectionView {
    static let reusableIdentifier = "imagesReusableIdentifier"
  }

  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    displayNoImagesMessage(assets.count == 0)
    return assets.count
  }

  public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionView.reusableIdentifier,
      forIndexPath: indexPath) as? ImageGalleryViewCell else { return UICollectionViewCell() }

    let asset = assets[indexPath.row]

    ImagePicker.resolveAsset(asset, size: CGSize(width: 160, height: 240)) { image in
      if let image = image {
        cell.configureCell(image)

        if indexPath.row == 0 && self.shouldTransform {
          cell.transform = CGAffineTransformMakeScale(0, 0)

          UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .CurveEaseInOut, animations: {
            cell.transform = CGAffineTransformIdentity
            }) { _ in }

          self.shouldTransform = false
        }

        if self.selectedStack.containsAsset(asset) {
          cell.selectedImageView.image = self.getImage("selectedImageGallery")
          cell.selectedImageView.alpha = 1
          cell.selectedImageView.transform = CGAffineTransformIdentity
        } else {
          cell.selectedImageView.image = nil
        }
      }
    }

    return cell
  }
}
