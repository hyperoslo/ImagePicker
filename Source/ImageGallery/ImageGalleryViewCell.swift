import UIKit

class ImageGalleryViewCell: UICollectionViewCell {

  lazy var imageView = UIImageView()
  lazy var selectedImageView = UIImageView()

  override init(frame: CGRect) {
    super.init(frame: frame)

    for view in [imageView, selectedImageView] {
      view.contentMode = .ScaleAspectFill
      view.translatesAutoresizingMaskIntoConstraints = false
      view.clipsToBounds = true
      contentView.addSubview(view)
    }
    setupConstraints()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  func configureCell(image: UIImage) {
    imageView.image = image
  }
}
