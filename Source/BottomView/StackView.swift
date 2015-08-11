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
    println(views.count)
    views.map{ self.addSubview($0) }

    layoutSubviews()
    ImageStack.sharedStack.delegate = self
  }

  override func layoutSubviews() {
    let step = -4
    for (i, view) in enumerate(views) {
      println("a")
      var side = i * step
      var frame = CGRect(origin: CGPoint(x: side, y: side), size: viewSize)
      view.frame = frame
      view.backgroundColor = UIColor.redColor()
      view.layer.borderColor = UIColor.blackColor().CGColor
      view.layer.borderWidth = 1
    }
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension StackView: ImageStackDelegate {
  func imageStackDidReload() {
    for (index, image) in enumerate(ImageStack.sharedStack.images) {
      if index < 4 {
        views[index].image = image
      }
    }
  }
}
