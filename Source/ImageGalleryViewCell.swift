import UIKit

class ImageGalleryViewCell: UICollectionViewCell {

  lazy var imageView: UIImageView = { [unowned self] in
    let imageView = UIImageView()
    imageView.contentMode = .ScaleAspectFill
    imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
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
      let attributes: [NSLayoutAttribute] = [.Width, .Height, .CenterX, .CenterY]

      attributes.map {
        self.addConstraint(NSLayoutConstraint(item: self.imageView, attribute: $0,
          relatedBy: .Equal, toItem: self, attribute: $0,
          multiplier: 1, constant: 0))
      }

      constraintsAdded = true
    }
  }
}
