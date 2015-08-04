import UIKit

class ImageWrapper: UIView {

  lazy var firstImageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
    }()

  lazy var secondImageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
    }()

  // MARK: - Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)

    setupConfigureImageViews()
    setupConstraints()
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  func setupConfigureImageViews() {
    [firstImageView, secondImageView].map { $0.layer.cornerRadius = 3 }
    [firstImageView, secondImageView].map { $0.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.75).CGColor }
    [firstImageView, secondImageView].map { $0.layer.borderWidth = 1 }
    [firstImageView, secondImageView].map { $0.contentMode = .ScaleAspectFill }
    [firstImageView, secondImageView].map { self.addSubview($0) }
  }

  // MARK: - Autolayout

  func setupConstraints() {
    [firstImageView, secondImageView].map { self.addConstraint(NSLayoutConstraint(item: $0, attribute: .Height,
      relatedBy: .Equal, toItem: self, attribute: .Height,
      multiplier: 1, constant: 0))
    }

    [firstImageView, secondImageView].map { self.addConstraint(NSLayoutConstraint(item: $0, attribute: .Width,
      relatedBy: .Equal, toItem: self, attribute: .Width,
      multiplier: 1, constant: 0))
    }

    addConstraint(NSLayoutConstraint(item: firstImageView, attribute: .CenterX,
      relatedBy: .Equal, toItem: self, attribute: .CenterX,
      multiplier: 1, constant: 0))

    addConstraint(NSLayoutConstraint(item: firstImageView, attribute: .CenterX,
      relatedBy: .Equal, toItem: self, attribute: .CenterX,
      multiplier: 1, constant: -5))

    addConstraint(NSLayoutConstraint(item: secondImageView, attribute: .CenterY,
      relatedBy: .Equal, toItem: self, attribute: .CenterY,
      multiplier: 1, constant: 0))

    addConstraint(NSLayoutConstraint(item: secondImageView, attribute: .CenterY,
      relatedBy: .Equal, toItem: self, attribute: .CenterY,
      multiplier: 1, constant: -5))
  }
}
