import UIKit

class ImageWrapper: UIView {

  struct Dimensions {
    static let imageSize: CGFloat = 52
  }

  lazy var firstImageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
    }()

  lazy var secondImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.alpha = 0

    return imageView
    }()

  lazy var thirdImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.alpha = 0

    return imageView
    }()

  lazy var fourthImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.alpha = 0

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
    [firstImageView, secondImageView, thirdImageView, fourthImageView].map { $0.layer.cornerRadius = 3 }
    [firstImageView, secondImageView, thirdImageView, fourthImageView].map { $0.layer.borderColor = UIColor(white: 1, alpha: 0.2).CGColor }
    [firstImageView, secondImageView, thirdImageView, fourthImageView].map { $0.layer.borderWidth = 1 }
    [firstImageView, secondImageView, thirdImageView, fourthImageView].map { $0.contentMode = .ScaleAspectFill }
    [firstImageView, secondImageView, thirdImageView, fourthImageView].map { $0.clipsToBounds = true }
    [firstImageView, secondImageView, thirdImageView, fourthImageView].map { $0.setTranslatesAutoresizingMaskIntoConstraints(false) }
    [firstImageView, secondImageView, thirdImageView, fourthImageView].map { self.addSubview($0) }
  }

  // MARK: - Autolayout

  func setupConstraints() {
    [firstImageView, secondImageView, thirdImageView, fourthImageView].map { self.addConstraint(NSLayoutConstraint(item: $0, attribute: .Height,
      relatedBy: .Equal, toItem: self, attribute: .Height,
      multiplier: 1, constant: 0))
    }

    [firstImageView, secondImageView, thirdImageView, fourthImageView].map { self.addConstraint(NSLayoutConstraint(item: $0, attribute: .Width,
      relatedBy: .Equal, toItem: self, attribute: .Width,
      multiplier: 1, constant: 0))
    }

    addConstraint(NSLayoutConstraint(item: firstImageView, attribute: .CenterX,
      relatedBy: .Equal, toItem: self, attribute: .CenterX,
      multiplier: 1, constant: 0))

    addConstraint(NSLayoutConstraint(item: firstImageView, attribute: .CenterY,
      relatedBy: .Equal, toItem: self, attribute: .CenterY,
      multiplier: 1, constant: 0))

    addConstraint(NSLayoutConstraint(item: secondImageView, attribute: .CenterY,
      relatedBy: .Equal, toItem: self, attribute: .CenterY,
      multiplier: 1, constant: -2.5))

    addConstraint(NSLayoutConstraint(item: secondImageView, attribute: .CenterX,
      relatedBy: .Equal, toItem: self, attribute: .CenterX,
      multiplier: 1, constant: -2.5))

    addConstraint(NSLayoutConstraint(item: thirdImageView, attribute: .CenterY,
      relatedBy: .Equal, toItem: self, attribute: .CenterY,
      multiplier: 1, constant: -5))

    addConstraint(NSLayoutConstraint(item: thirdImageView, attribute: .CenterX,
      relatedBy: .Equal, toItem: self, attribute: .CenterX,
      multiplier: 1, constant: -5))

    addConstraint(NSLayoutConstraint(item: fourthImageView, attribute: .CenterY,
      relatedBy: .Equal, toItem: self, attribute: .CenterY,
      multiplier: 1, constant: -7.5))

    addConstraint(NSLayoutConstraint(item: fourthImageView, attribute: .CenterX,
      relatedBy: .Equal, toItem: self, attribute: .CenterX,
      multiplier: 1, constant: -7.5))
  }
}
