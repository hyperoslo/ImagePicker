import UIKit

class ImageGalleryView: UIView {

  struct Dimensions {
    static let galleryHeight: CGFloat = 160
    static let galleryBarHeight: CGFloat = 34
  }

  // MARK: - Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)

    setupConstraints()
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Layout

  func setupConstraints() {

  }
}
