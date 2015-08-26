import UIKit

protocol ImageStackViewDelegate {
  func imageStackViewDidPress()
}

class ImageStackView: UIView {

  struct Dimensions {
    static let imageSize: CGFloat = 70
  }

  var delegate: ImageStackViewDelegate?

  var views: [UIImageView] = {
    var array = [UIImageView]()
    for i in 0...3 {
      let view = UIImageView()
      view.layer.cornerRadius = 3
      view.layer.borderColor = UIColor(white: 1, alpha: 0.2).CGColor
      view.layer.borderWidth = 1
      view.contentMode = .ScaleAspectFill
      view.clipsToBounds = true
      view.alpha = 0
      array.append(view)
    }
    return array
    }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    subscribe()
    views.map { self.addSubview($0) }
    views[0].alpha = 1
    layoutSubviews()
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  func subscribe() {
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "imageDidPush:",
      name: ImageStack.Notifications.imageDidPushNotification,
      object: nil)

    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "imageStackDidChangeContent:",
      name: ImageStack.Notifications.imageDidDropNotification,
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

    for (i, view) in enumerate(views) {
      origin.x += step
      origin.y += step
      var frame = CGRect(origin: origin, size: viewSize)
      view.frame = frame
    }
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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

    let photos = suffix(images, 4)

    for (index, view) in enumerate(views) {
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

    UIView.animateWithDuration(0.3, animations: { [unowned self] in
      imageView.transform = CGAffineTransformMakeScale(1.05, 1.05)
      }, completion: { _ in
        UIView.animateWithDuration(0.2, animations: { _ in
          imageView.transform = CGAffineTransformIdentity
        })
    })
  }
}

