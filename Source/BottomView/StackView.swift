import UIKit
import Photos

protocol ImageStackViewDelegate: class {
  func imageStackViewDidPress()
}

class ImageStackView: UIView {

  struct Dimensions {
    static let imageSize: CGFloat = 58
  }

  weak var delegate: ImageStackViewDelegate?

  lazy var activityView: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView()
    view.alpha = 0.0

    return view
    }()

  var views: [UIImageView] = {
    var array = [UIImageView]()
    for i in 0...3 {
      let view = UIImageView()
      view.layer.cornerRadius = 3
      view.layer.borderColor = UIColor.whiteColor().CGColor
      view.layer.borderWidth = 1
      view.contentMode = .ScaleAspectFill
      view.clipsToBounds = true
      view.alpha = 0
      array.append(view)
    }
    return array
    }()

  // MARK: - Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)

    subscribe()

    views.forEach { addSubview($0) }
    addSubview(activityView)
    views.first?.alpha = 1
    layoutSubviews()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  // MARK: - Helpers

  func subscribe() {
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "imageDidPush:",
      name: ImageStack.Notifications.imageDidPush,
      object: nil)

    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "imageStackDidChangeContent:",
      name: ImageStack.Notifications.imageDidDrop,
      object: nil)

    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "imageStackDidChangeContent:",
      name: ImageStack.Notifications.stackDidReload,
      object: nil)
  }

  override func layoutSubviews() {
    let step: CGFloat = -3.0
    let scale: CGFloat = 0.8
    let viewSize = CGSize(width: frame.width * scale,
      height: frame.height * scale)

    let offset = -step * CGFloat(views.count)
    var origin = CGPoint(x: offset, y: offset)

    for view in views {
      origin.x += step
      origin.y += step
      view.frame = CGRect(origin: origin, size: viewSize)
    }
  }

  func startLoader() {
    if let firstVisibleView = views.filter({ $0.alpha == 1.0 }).last {
      activityView.frame.origin.x = firstVisibleView.center.x
      activityView.frame.origin.y = firstVisibleView.center.y
    }
  
    activityView.startAnimating()
    UIView.animateWithDuration(0.3) {
      self.activityView.alpha = 1.0
    }
  }
}

extension ImageStackView {

  func imageDidPush(notification: NSNotification) {
    let emptyView = views.filter { $0.image == nil }.first

    if let emptyView = emptyView {
      animateImageView(emptyView)
    }

    if let sender = notification.object as? ImageStack {
      renderViews(sender.assets)
      activityView.stopAnimating()
    }
  }

  func imageStackDidChangeContent(notification: NSNotification) {
    if let sender = notification.object as? ImageStack {
      renderViews(sender.assets)
      activityView.stopAnimating()
    }
  }

  func renderViews(assets: [PHAsset]) {
    if let firstView = views.first where assets.isEmpty {
      for imageView in views {
        imageView.image = nil
        imageView.alpha = 0
      }

      firstView.alpha = 1
      return
    }

    let photos = Array(assets.suffix(4))

    for (index, view) in views.enumerate() {
      if index <= photos.count - 1 {
        ImagePicker.resolveAsset(photos[index], size: CGSize(width: Dimensions.imageSize, height: Dimensions.imageSize)) { image in
          view.image = image
        }
        view.alpha = 1
      } else {
        view.image = nil
        view.alpha = 0
      }

      if index == photos.count {
        UIView.animateWithDuration(0.3) {
          self.activityView.frame.origin.x = view.center.x + 3
          self.activityView.frame.origin.y = view.center.y + 3
        }
      }
    }
  }

  private func animateImageView(imageView: UIImageView) {
    imageView.transform = CGAffineTransformMakeScale(0, 0)

    UIView.animateWithDuration(0.3, animations: {
      imageView.transform = CGAffineTransformMakeScale(1.05, 1.05)
      }) { _ in
        UIView.animateWithDuration(0.2, animations: { () -> Void in
          self.activityView.alpha = 0.0
          imageView.transform = CGAffineTransformIdentity
          }, completion: { _ in
            self.activityView.stopAnimating()
        })
    }
  }
}
