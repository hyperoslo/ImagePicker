import UIKit

public struct Configuration {

  // MARK: Colors

  public var backgroundColor = UIColor(red: 0.15, green: 0.19, blue: 0.24, alpha: 1)
  public var gallerySeparatorColor = UIColor.black.withAlphaComponent(0.6)
  public var mainColor = UIColor(red: 0.09, green: 0.11, blue: 0.13, alpha: 1)
  public var noImagesColor = UIColor(red: 0.86, green: 0.86, blue: 0.86, alpha: 1)
  public var noCameraColor = UIColor(red: 0.86, green: 0.86, blue: 0.86, alpha: 1)
  public var settingsColor = UIColor.white
  public var bottomContainerColor = UIColor(red: 0.09, green: 0.11, blue: 0.13, alpha: 1)

  // MARK: Fonts

  public var numberLabelFont = UIFont(name: "HelveticaNeue-Bold", size: 19)!
  public var doneButton = UIFont(name: "HelveticaNeue-Medium", size: 19)!
  public var flashButton = UIFont(name: "HelveticaNeue-Medium", size: 12)!
  public var noImagesFont = UIFont(name: "HelveticaNeue-Medium", size: 18)!
  public var noCameraFont = UIFont(name: "HelveticaNeue-Medium", size: 18)!
  public var settingsFont = UIFont(name: "HelveticaNeue-Medium", size: 16)!

  // MARK: Titles

  public var OKButtonTitle = "OK"
  public var cancelButtonTitle = "Cancel"
  public var doneButtonTitle = "Done"
  public var noImagesTitle = "No images available"
  public var noCameraTitle = "Camera is not available"
  public var settingsTitle = "Settings"
  public var requestPermissionTitle = "Permission denied"
  public var requestPermissionMessage = "Please, allow the application to access to your photo library."

  // MARK: Dimensions

  public var cellSpacing: CGFloat = 2
  public var indicatorWidth: CGFloat = 41
  public var indicatorHeight: CGFloat = 8

  // MARK: Custom behaviour

  public var canRotateCamera = true
  public var collapseCollectionViewWhileShot = true
  public var recordLocation = true
  public var allowMultiplePhotoSelection = true

  // MARK: Images
  public var indicatorView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.white.withAlphaComponent(0.6)
    view.layer.cornerRadius = 4
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

}
