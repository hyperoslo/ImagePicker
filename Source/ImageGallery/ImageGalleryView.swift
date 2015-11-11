import UIKit
import Photos

protocol ImageGalleryPanGestureDelegate: class {

  func panGestureDidStart()
  func panGestureDidChange(translation: CGPoint)
  func panGestureDidEnd(translation: CGPoint, velocity: CGPoint)
  func presentViewController(controller: UIAlertController)
  func dismissViewController(controller: UIAlertController)
  func permissionGranted()
  func hideViews()
}

public class ImageGalleryView: UIView {

  struct Dimensions {
    static let galleryHeight: CGFloat = 160
    static let galleryBarHeight: CGFloat = 24
    static let indicatorWidth: CGFloat = 41
    static let indicatorHeight: CGFloat = 8
  }

  lazy public var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: CGRectMake(0, 0, 0, 0),
      collectionViewLayout: self.collectionViewLayout)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.backgroundColor = self.pickerConfiguration.mainColor
    collectionView.showsHorizontalScrollIndicator = false

    return collectionView
    }()

  lazy var collectionViewLayout: UICollectionViewLayout = { [unowned self] in
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .Horizontal
    layout.minimumInteritemSpacing = self.pickerConfiguration.cellSpacing
    layout.minimumLineSpacing = 2
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)

    return layout
    }()

  lazy var topSeparator: UIView = { [unowned self] in
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.addGestureRecognizer(self.panGestureRecognizer)
    view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)

    return view
    }()

  lazy var indicator: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.6)
    view.layer.cornerRadius = Dimensions.indicatorHeight / 2
    view.translatesAutoresizingMaskIntoConstraints = false
    
    return view
    }()

  lazy var panGestureRecognizer: UIPanGestureRecognizer = { [unowned self] in
    let gesture = UIPanGestureRecognizer()
    gesture.addTarget(self, action: "handlePanGestureRecognizer:")

    return gesture
    }()

  lazy var selectedStack = ImageStack()

  lazy var assets = [PHAsset]()

  lazy var pickerConfiguration: Configuration = Configuration.sharedInstance

  public lazy var noImagesLabel: UILabel = { [unowned self] in
    let label = UILabel()
    label.font = self.pickerConfiguration.noImagesFont
    label.textColor = self.pickerConfiguration.noImagesColor
    label.text = self.pickerConfiguration.noImagesTitle
    label.alpha = 0
    label.sizeToFit()
    self.addSubview(label)
    
    return label
    }()

  weak var delegate: ImageGalleryPanGestureDelegate?
  var collectionSize: CGSize!
  var shouldTransform = false
  var imagesBeforeLoading = 0
  var fetchResult: PHFetchResult?
  var canFetchImages = false

  // MARK: - Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)

    collectionView.registerClass(ImageGalleryViewCell.self,
      forCellWithReuseIdentifier: CollectionView.reusableIdentifier)

    [collectionView, topSeparator].forEach { addSubview($0) }

    topSeparator.addSubview(indicator)
    imagesBeforeLoading = 0
    fetchPhotos()
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Layout

  func updateFrames() {
    let totalWidth = UIScreen.mainScreen().bounds.width
    let collectionFrame = frame.height == Dimensions.galleryBarHeight ? 100 + Dimensions.galleryBarHeight : frame.height

    collectionView.dataSource = self
    collectionView.delegate = self

    topSeparator.frame = CGRect(x: 0, y: 0, width: totalWidth, height: Dimensions.galleryBarHeight)
    indicator.frame = CGRect(x: (totalWidth - Dimensions.indicatorWidth) / 2, y: (topSeparator.frame.height - Dimensions.indicatorHeight) / 2,
      width: Dimensions.indicatorWidth, height: Dimensions.indicatorHeight)
    collectionView.frame = CGRect(x: 0, y: topSeparator.frame.height, width: totalWidth, height: collectionFrame - topSeparator.frame.height)
    collectionSize = CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    noImagesLabel.center = collectionView.center
  }

  // MARK: - Photos handler

  func fetchPhotos(completion: (() -> Void)? = nil) {
    Photos.fetch { assets in
      self.assets.removeAll()
      self.assets.appendContentsOf(assets)
      self.collectionView.reloadData()

      completion?()
    }
  }

  // MARK: - Pan gesture recognizer

  func handlePanGestureRecognizer(gesture: UIPanGestureRecognizer) {
    let translation = gesture.translationInView(superview!)
    let velocity = gesture.velocityInView(superview!)

    switch gesture.state {
    case .Began:
      delegate?.panGestureDidStart()
    case .Changed:
      delegate?.panGestureDidChange(translation)
    case .Ended:
      delegate?.panGestureDidEnd(translation, velocity: velocity)
    default: break
    }
  }

  // MARK: - Private helpers

  func getImage(name: String) -> UIImage {
    let bundlePath = NSBundle(forClass: self.classForCoder).resourcePath?.stringByAppendingString("/ImagePicker.bundle")
    let bundle = NSBundle(path: bundlePath!)
    let traitCollection = UITraitCollection(displayScale: 3)
    let image = UIImage(named: name, inBundle: bundle, compatibleWithTraitCollection: traitCollection)

    return image!
  }

  func displayNoImagesMessage(hideCollectionView: Bool) {
    collectionView.alpha = hideCollectionView ? 0 : 1
    noImagesLabel.alpha = hideCollectionView ? 1 : 0
  }

  func checkStatus() {
    let currentStatus = PHPhotoLibrary.authorizationStatus()

    guard currentStatus != .Authorized else { return }

    if currentStatus == .NotDetermined {
      delegate?.hideViews()
    }

    PHPhotoLibrary.requestAuthorization { (authorizationStatus) -> Void in
      dispatch_async(dispatch_get_main_queue(), {
        if authorizationStatus == .Denied {
          let alertController = UIAlertController(title: "Permission denied", message: "Please, allow the application to access to your photo library.", preferredStyle: .Alert)

          let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { _ in
            if let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString) {
              UIApplication.sharedApplication().openURL(settingsURL)
            }
          }

          let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { _ in
            self.delegate?.dismissViewController(alertController)
          }

          alertController.addAction(alertAction)
          alertController.addAction(cancelAction)
          self.delegate?.presentViewController(alertController)
        } else if authorizationStatus == .Authorized {
          self.delegate?.permissionGranted()
        }
      })
    }
  }
}

// MARK: CollectionViewFlowLayout delegate methods

extension ImageGalleryView: UICollectionViewDelegateFlowLayout {

  public func collectionView(collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
      return collectionSize
  }
}

// MARK: CollectionView delegate methods

extension ImageGalleryView: UICollectionViewDelegate {

  public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ImageGalleryViewCell
    let asset = assets[indexPath.row]

    Photos.resolveAsset(asset) { image in
      guard let _ = image else { return }

      if cell.selectedImageView.image != nil {
        UIView.animateWithDuration(0.2, animations: {
          cell.selectedImageView.transform = CGAffineTransformMakeScale(0.1, 0.1)
          }) { _ in
            cell.selectedImageView.image = nil
        }
        self.selectedStack.dropAsset(asset)
      } else {
        cell.selectedImageView.image = self.getImage("selectedImageGallery")
        cell.selectedImageView.transform = CGAffineTransformMakeScale(0, 0)
        UIView.animateWithDuration(0.2) { _ in
          cell.selectedImageView.transform = CGAffineTransformIdentity
        }
        self.selectedStack.pushAsset(asset)
      }
    }
  }

  public func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
    guard indexPath.row + 10 >= assets.count
      && indexPath.row < fetchResult?.count
      && canFetchImages else { return }

    fetchPhotos()
    canFetchImages = false
  }
}
