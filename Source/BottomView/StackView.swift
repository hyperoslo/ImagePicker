import UIKit

class StackView: UIView {

  var views: [UIImageView] = {
    var array = [UIImageView]()
    for i in 0...3 {
      let view = UIImageView()
      view.layer.cornerRadius = 3
      view.layer.borderColor = UIColor(white: 1, alpha: 0.2).CGColor
      view.layer.borderWidth = 1
      view.contentMode = .ScaleAspectFill
      view.clipsToBounds = true
//      view.addGestureRecognizer(self.tapGestureRecognizer)
      array.append(view)
    }
    return array
    }()

  lazy var tapGestureRecognizer: UITapGestureRecognizer = {
    let gesture = UITapGestureRecognizer()
    gesture.addTarget(self, action: "handleTapGestureRecognizer:")

    return gesture
    }()
  lazy var viewSize: CGSize = CGSize(width: self.frame.width * 0.6, height: self.frame.height * 0.6)

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.blueColor()
    views.map{ self.addSubview($0) }

    layoutSubviews()
    ImageStack.sharedStack.delegate = self
  }

  override func layoutSubviews() {
    let step = -4
    for (i, view) in enumerate(views) {
      var side = i * step
      var frame = CGRect(origin: CGPoint(x: side, y: side), size: viewSize)
      view.frame = frame
    }
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension StackView: ImageStackDelegate {
  func imageDidPush(image: UIImage) {
renderViews()
  }

  func imageStackDidDrop(image: UIImage) {
renderViews()
  }

  func renderViews() {
    let photos = ImageStack.sharedStack.images
    if photos.isEmpty {
      return
    }
    //TODO: Find better way to limit value to bounds
    var size = min(photos.count - 1, 3)
    size = max(size, 0)
    let lastFour = photos.reverse()[0...size].reverse()
    Array(map(enumerate(lastFour)) { (index, image) in
      self.views[index].image = image
      })
  }
}