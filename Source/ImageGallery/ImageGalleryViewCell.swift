import UIKit

class ImageGalleryViewCell: UICollectionViewCell {

  lazy var imageView: UIImageView = { [unowned self] in
    let imageView = UIImageView()
    imageView.contentMode = .ScaleAspectFill
    imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    imageView.clipsToBounds = true
    self.contentView.addSubview(imageView)

    return imageView
    }()

  lazy var selectedImageView: UIImageView = { [unowned self] in
    let imageView = UIImageView()
    imageView.contentMode = .ScaleAspectFill
    imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    imageView.clipsToBounds = true
    self.contentView.addSubview(imageView)

    return imageView
    }()

  var constraintsAdded = false

  // MARK: - Configuration

  func configureCell(image: UIImage) {
    imageView.image = image
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
