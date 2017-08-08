import UIKit

class ImageGalleryViewCell: UICollectionViewCell {

  lazy var imageView = UIImageView()
  lazy var selectedImageView = UIImageView()
  private var videoInfoView: VideoInfoView

  private let videoInfoBarHeight: CGFloat = 15
  var duration: TimeInterval? {
    didSet {
      if let duration = duration, duration > 0 {
        self.videoInfoView.duration = duration
        self.videoInfoView.isHidden = false
      } else {
        self.videoInfoView.isHidden = true
      }
    }
  }

  override init(frame: CGRect) {
    let videoBarFrame = CGRect(x: 0, y: frame.height - self.videoInfoBarHeight,
                               width: frame.width, height: self.videoInfoBarHeight)
    videoInfoView = VideoInfoView(frame: videoBarFrame)
    super.init(frame: frame)

    for view in [imageView, selectedImageView, videoInfoView] as [UIView] {
      view.contentMode = .scaleAspectFill
      view.translatesAutoresizingMaskIntoConstraints = false
      view.clipsToBounds = true
      contentView.addSubview(view)
    }

    isAccessibilityElement = true
    accessibilityLabel = "Photo"

    setupConstraints()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  func configureCell(_ image: UIImage) {
    imageView.image = image
  }
}
