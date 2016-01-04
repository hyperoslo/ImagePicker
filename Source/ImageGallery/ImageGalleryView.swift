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
    collectionView.backgroundColor = Configuration.mainColor
    collectionView.showsHorizontalScrollIndicator = false

    return collectionView
    }()

  lazy var collectionViewLayout: UICollectionViewLayout = { [unowned self] in
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .Horizontal
    layout.minimumInteritemSpacing = Configuration.cellSpacing
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

  public lazy var noImagesLabel: UILabel = { [unowned self] in
    let label = UILabel()
    label.font = Configuration.noImagesFont
    label.textColor = Configuration.noImagesColor
    label.text = Configuration.noImagesTitle
    label.alpha = 0
    label.sizeToFit()
    self.addSubview(label)
    
    return label
    }()

  public lazy var selectedStack = ImageStack()
  lazy var assets = [PHAsset]()

  weak var delegate: ImageGalleryPanGestureDelegate?
  var collectionSize: CGSize?
  var shouldTransform = false
  var imagesBeforeLoading = 0
  var fetchResult: PHFetchResult?
  var canFetchImages = false
  var imageLimit = 0

  // MARK: - Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)

    backgroundColor = Configuration.mainColor

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

  public override func layoutSubviews() {
    super.layoutSubviews()
    updateNoImagesLabel()
  }

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
  }

  func updateNoImagesLabel() {
    let height = CGRectGetHeight(bounds)
    let threshold = Dimensions.galleryBarHeight * 2
    if threshold > height || collectionView.alpha != 0 {
      noImagesLabel.alpha = 0
    } else {
      noImagesLabel.center = CGPoint(x: CGRectGetWidth(bounds)/2, y: height/2)
      noImagesLabel.alpha = (height > threshold) ? 1 : (height - Dimensions.galleryBarHeight) / threshold
    }
  }

  // MARK: - Photos handler

  func fetchPhotos(completion: (() -> Void)? = nil) {
    ImagePicker.fetch { assets in
      self.assets.removeAll()
      self.assets.appendContentsOf(assets)
      self.collectionView.reloadData()

      completion?()
    }
  }

  // MARK: - Pan gesture recognizer

  func handlePanGestureRecognizer(gesture: UIPanGestureRecognizer) {
    guard let superview = superview else { return }

    let translation = gesture.translationInView(superview)
    let velocity = gesture.velocityInView(superview)

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
    guard let bundlePath = NSBundle(forClass: self.classForCoder).resourcePath?.stringByAppendingString("/ImagePicker.bundle") else { return UIImage() }

    let bundle = NSBundle(path: bundlePath)
    let traitCollection = UITraitCollection(displayScale: 3)
    
    guard let image = UIImage(named: name, inBundle: bundle, compatibleWithTraitCollection: traitCollection)
      else { return UIImage() }

    return image
  }

  func displayNoImagesMessage(hideCollectionView: Bool) {
    collectionView.alpha = hideCollectionView ? 0 : 1
    updateNoImagesLabel()
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
      guard let collectionSize = collectionSize else { return CGSizeZero }

      return collectionSize
  }
}

// MARK: CollectionView delegate methods

extension ImageGalleryView: UICollectionViewDelegate {

  public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    guard let cell = collectionView.cellForItemAtIndexPath(indexPath)
      as? ImageGalleryViewCell else { return }

    let asset = assets[indexPath.row]

    ImagePicker.resolveAsset(asset) { image in
      guard let _ = image else { return }

      if cell.selectedImageView.image != nil {
        UIView.animateWithDuration(0.2, animations: {
          cell.selectedImageView.transform = CGAffineTransformMakeScale(0.1, 0.1)
          }) { _ in
            cell.selectedImageView.image = nil
        }
        self.selectedStack.dropAsset(asset)
      } else if self.imageLimit == 0 || self.imageLimit > self.selectedStack.assets.count {
        cell.selectedImageView.image = self.getImage("selectedImageGallery")
        cell.selectedImageView.transform = CGAffineTransformMakeScale(0, 0)
        UIView.animateWithDuration(0.2) { _ in
          cell.selectedImageView.transform = CGAffineTransformIdentity
        }
        self.selectedStack.pushAsset(asset)
      }
    }
  }

  public func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell,
    forItemAtIndexPath indexPath: NSIndexPath) {
      guard indexPath.row + 10 >= assets.count
        && indexPath.row < fetchResult?.count
        && canFetchImages else { return }

      fetchPhotos()
      canFetchImages = false
  }
}
