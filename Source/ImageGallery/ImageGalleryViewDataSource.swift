import UIKit

extension ImageGalleryView: UICollectionViewDataSource {

	public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		displayNoImagesMessage(assets.isEmpty)
		return assets.count
	}

	public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as ImageGalleryViewCell
		let asset = assets[indexPath.row]

		AssetManager.resolveAsset(asset, size: CGSize(width: 160, height: 240)) { image in
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
					cell.selectedImageView.image = AssetManager.getImage("selectedImageGallery")
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
