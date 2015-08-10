import UIKit

class StackView: UIView {

  let stack: ImageStack = ImageStack.sharedStack
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
    addViews()
    layoutSubviews()
  }

  func addViews() {
    views.map{ self.addSubview($0) }
  }

  override func layoutSubviews() {
    let m = -4
    for (i, view) in enumerate(views) {
      println("a")
      var w = i * m
      var frame = CGRect(origin: CGPoint(x: w, y: w), size: viewSize)
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
