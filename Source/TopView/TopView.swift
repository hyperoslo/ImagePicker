import UIKit

class TopView: UIView {

  struct Dimensions {
    static let leftOffset: CGFloat = 11
    static let rightOffset: CGFloat = 11
  }

  lazy var flashButton: UIButton = {
    let button = UIButton()
    return button
    }()

  lazy var rotateCamera: UIButton = {
    let button = UIButton()
    return button
    }()

  // MARK: - Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)

    [flashButton, rotateCamera].map { self.addSubview($0) }

    setupConstraints()
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Constraints

  func setupConstraints() {
    addConstraint(NSLayoutConstraint(item: flashButton, attribute: .Left,
      relatedBy: .Equal, toItem: self, attribute: .Left,
      multiplier: 1, constant: Dimensions.leftOffset))

    addConstraint(NSLayoutConstraint(item: flashButton, attribute: .CenterY,
      relatedBy: .Equal, toItem: self, attribute: .CenterY,
      multiplier: 1, constant: 0))

    addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .Right,
      relatedBy: .Equal, toItem: self, attribute: .Right,
      multiplier: 1, constant: -Dimensions.rightOffset))

    addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .CenterY,
      relatedBy: .Equal, toItem: self, attribute: .CenterY,
      multiplier: 1, constant: 0))
  }
}
