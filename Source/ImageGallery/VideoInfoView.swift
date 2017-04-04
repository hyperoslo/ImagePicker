import UIKit

class VideoInfoView: UIView {
    
  private var duration: TimeInterval?

  private lazy var videoIcon: UIImageView = {
    var videoIcon = UIImageView(image: AssetManager.getImage("video"))
    videoIcon.frame = CGRect(x: 3,
                             y: 0,
                             width: self.bounds.height,
                             height: self.bounds.height)
    videoIcon.contentMode = .scaleAspectFit
    return videoIcon
  }()
    
  private lazy var videoInfoLabel: UILabel = {
    let videoInfoLabel = UILabel(frame: CGRect(x: 0,
                                               y: 0,
                                               width: self.bounds.width - 5,
                                               height: self.bounds.height))
    videoInfoLabel.font = UIFont.systemFont(ofSize: 10)
    videoInfoLabel.textColor = .white
    videoInfoLabel.textAlignment = .right
    videoInfoLabel.text = self.dateFormatter.string(from: self.duration ?? 0)
    return videoInfoLabel
  }()
    
  private lazy var dateFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.zeroFormattingBehavior = .pad
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.unitsStyle = .positional
    return formatter
  }()

  init(frame: CGRect, duration: TimeInterval) {
    super.init(frame: frame)

    self.duration = duration
    backgroundColor = UIColor(white: 0, alpha: 0.5)
    addSubview(self.videoIcon)
    addSubview(self.videoInfoLabel)
  }

  override init(frame: CGRect) {
    fatalError("init(frame:) has not been implemented")
  }
    
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
