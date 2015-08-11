import UIKit

protocol ImageStackDelegate {
   func imageStackDidReload()
}

struct ImageStack {

  static var sharedStack = ImageStack()

  var images: NSMutableArray = NSMutableArray()
  var delegate: ImageStackDelegate?

  func pushImage(image: UIImage) {
    images.insertObject(image, atIndex: 0)
    delegate?.imageStackDidReload()
    println("Image pushed")
    println(images)
  }

  func dropImage(image: UIImage) {
    images.removeObject(image)
    delegate?.imageStackDidReload()
    println("Image dropped")
    println(images)
  }

  func containsImage(image: UIImage) -> Bool {
    return images.containsObject(image)
  }

  func getImages() -> [UIImage] {
//    let size = images.count > 4 ? 3 : images.count
//    var array = [UIImage]()
//    for i in 0...size {
//      array.append(images[i] as! UIImage)
//    }
//    return array
          println("b")
    var array: [UIImage] = [UIImage]()
    for image in images {
      println("a")
      array.append(image as! UIImage)
    }
return array
  }
}
