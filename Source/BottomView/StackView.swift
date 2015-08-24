import UIKit

protocol StackViewDelegate {
  func stackViewDidPress()
}

class StackView: UIView {

  struct Dimensions {
    static let imageSize: CGFloat = 70
  }

  var delegate: StackViewDelegate?

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

  lazy var tapGestureRecognizer: UITapGestureRecognizer = {
    let gesture = UITapGestureRecognizer()
    gesture.addTarget(self, action: "handleTapGestureRecognizer:")

    return gesture
    }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    subscribe()
    views.map{ self.addSubview($0) }
    views[0].alpha = 1
    self.addGestureRecognizer(tapGestureRecognizer)
    layoutSubviews()
    //renderViews()
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
      selector: "imageStackDidDrop:",
      name: ImageStack.Notifications.imageDidDropNotification,
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

  func handleTapGestureRecognizer(gesture: UITapGestureRecognizer) {
    delegate?.stackViewDidPress()
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension StackView {
  func imageDidPush(notification: NSNotification) {

    //TODO indexOf in swift 2
    let emptyView = views.filter( {$0.image == nil} ).first

    if let emptyView = emptyView {
      animateImageView(emptyView)
    }
    if let sender = notification.object as? ImageStack {
      renderViews(sender.images)
    }
  }

  func imageStackDidDrop(notification: NSNotification) {
    if let sender = notification.object as? ImageStack {
      if let userInfo = notification.userInfo as? [String : UIImage] {
        // // Uncomment if you want fancy animations
        //      let image = userInfo[ImageStack.Notifications.imageKey]
        //      let viewToEmpty = views.filter( {$0.image == image} ).first
        //
        //      if let viewToEmpty = viewToEmpty {
        //        animateImageView(viewToEmpty)
        //      }
        
        renderViews(sender.images)
      }
    }
  }

  func renderViews(images: [UIImage]) {
    //because Swift is not functional language
    if images.count < 1 {
      views.map { $0.image = nil}
      return
    }

    let photos = suffix(images, 4)

    //TODO: This can be done in functional-style
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

