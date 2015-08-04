import UIKit

class ImageWrapper: UIView {

  // MARK: - Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)

    setupConstraints()
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Autolayout

  func setupConstraints() {

  }
}
