import UIKit

class ImageGalleryViewCell: UICollectionViewCell {

  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .ScaleAspectFill

    return imageView
    }()

  var constraintsAdded = false

  // MARK: - Configuration

  func configureCell(image: UIImage) {
    addSubview(imageView)
    imageView.image = image

    setupConstraints()
  }

  // MARK: - Autolayout

  func setupConstraints() {
    if !constraintsAdded {
      addConstraint(NSLayoutConstraint(item: imageView, attribute: .Width,
        relatedBy: .Equal, toItem: self, attribute: .Width,
        multiplier: 1, constant: -2))

      addConstraint(NSLayoutConstraint(item: imageView, attribute: .Height,
        relatedBy: .Equal, toItem: self, attribute: .Height,
        multiplier: 1, constant: 0))

      addConstraint(NSLayoutConstraint(item: imageView, attribute: .CenterX,
        relatedBy: .Equal, toItem: self, attribute: .CenterX,
        multiplier: 1, constant: 0))

      addConstraint(NSLayoutConstraint(item: imageView, attribute: .CenterY,
        relatedBy: .Equal, toItem: self, attribute: .CenterY,
        multiplier: 1, constant: 0))

      constraintsAdded = true
    }
  }
}
