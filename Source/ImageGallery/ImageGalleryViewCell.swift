import UIKit

class ImageGalleryViewCell: UICollectionViewCell {

  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
    }()

  lazy var selectedImageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
    }()

  var constraintsAdded = false

  // MARK: - Configuration

  func configureCell(image: UIImage) {
    imageView.image = image

    if imageView.superview != contentView {
      for view in [imageView, selectedImageView] {
        view.contentMode = .ScaleAspectFill
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.clipsToBounds = true
        contentView.addSubview(view)
      }
    }

    setupConstraints()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    setupConstraints()
  }

  // MARK: - Autolayout

  func setupConstraints() {
    if !constraintsAdded {
      for attribute: NSLayoutAttribute in [.Width, .Height, .CenterX, .CenterY] {
        addConstraint(NSLayoutConstraint(item: imageView, attribute: attribute,
          relatedBy: .Equal, toItem: self, attribute: attribute,
          multiplier: 1, constant: 0))

        addConstraint(NSLayoutConstraint(item: selectedImageView, attribute: attribute,
          relatedBy: .Equal, toItem: self, attribute: attribute,
          multiplier: 1, constant: 0))
      }

      constraintsAdded = true
    }
  }
}
