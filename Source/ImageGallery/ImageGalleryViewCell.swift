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
}
