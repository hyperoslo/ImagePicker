import UIKit

class ImageGalleryViewCell: UICollectionViewCell {

  lazy var imageView = UIImageView()
  lazy var selectedImageView = UIImageView()
  var videoInfoView: VideoInfoView?
  
  private let videoInfoBarHeight: CGFloat = 15
  var duration: TimeInterval? {
    didSet {
        guard let duration = duration, duration > 0 else {
            self.videoInfoView?.removeFromSuperview()
            return
        }

        let frame = CGRect(x: 0, y: self.bounds.height - self.videoInfoBarHeight,
                           width: self.bounds.width, height: self.videoInfoBarHeight)
        videoInfoView = VideoInfoView(frame: frame, duration: duration)
        contentView.addSubview(videoInfoView!)
    }
  }
  

  override init(frame: CGRect) {
    super.init(frame: frame)

    for view in [imageView, selectedImageView] {
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
