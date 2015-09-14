import UIKit

protocol ImageStackViewDelegate: class {
  func imageStackViewDidPress()
}

class ImageStackView: UIView {

  struct Dimensions {
    static let imageSize: CGFloat = 58
  }

  weak var delegate: ImageStackViewDelegate?

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

    for view in views {
      addSubview(view)
    }
    
    views[0].alpha = 1
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
    let viewSize = CGSize(width: self.frame.width * scale,
      height: self.frame.height * scale)

    let offset = -step * CGFloat(views.count)
    var origin = CGPoint(x: offset, y: offset)

    for (_, view) in views.enumerate() {
      origin.x += step
      origin.y += step
      let frame = CGRect(origin: origin, size: viewSize)
      view.frame = frame
    }
  }
}

extension ImageStackView {

  func imageDidPush(notification: NSNotification) {

    //TODO indexOf in swift 2
    let emptyView = views.filter {$0.image == nil}.first

    if let emptyView = emptyView {
      animateImageView(emptyView)
    }
    if let sender = notification.object as? ImageStack {
      renderViews(sender.images)
    }
  }

  func imageStackDidChangeContent(notification: NSNotification) {
    if let sender = notification.object as? ImageStack {
      renderViews(sender.images)
    }
  }

  func renderViews(images: [UIImage]) {
    if images.count < 1 {
      //TODO: subclass view and use setimage method here to automatically adjust alpha and NIL
      for imageView in views {
        imageView.image = nil
        imageView.alpha = 0
      }

      views.first!.alpha = 1
      return
    }

    let photos = Array(images.suffix(4))

    for (index, view) in views.enumerate() {
      if index <= photos.count - 1 {
        view.image = photos[index]
        view.alpha = 1
      } else {
        view.image = nil
        view.alpha = 0
      }
    }
  }

  private func animateImageView(imageView: UIImageView) {
    imageView.transform = CGAffineTransformMakeScale(0, 0)

    UIView.animateWithDuration(0.3, animations: {
      imageView.transform = CGAffineTransformMakeScale(1.05, 1.05)
      }, completion: { _ in
        UIView.animateWithDuration(0.2, animations: { _ in
          imageView.transform = CGAffineTransformIdentity
        })
    })
  }
}
