import UIKit

class StackView: UIView {

  var views: [UIImageView] = {
    var array = [UIImageView]()
    for i in 1...4 {
      array.append(UIImageView())
    }
    return array
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
  func imageStackDidReload() {
    let photos = ImageStack.sharedStack.images
    let size = min(photos.count - 1, 3)
    let lastFour = photos.reverse()[0...size].reverse()
    for (index, image) in enumerate(lastFour) {
        views[index].image = image
    }
  }
}