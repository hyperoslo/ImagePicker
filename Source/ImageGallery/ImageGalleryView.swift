import UIKit
import Photos
import AssetsLibrary

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
    static let galleryBarHeight: CGFloat = 24
    static let indicatorSize = CGSize(width: 41, height: 8)
  }

  lazy public var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: CGRectMake(0, 0, 0, 0),
      collectionViewLayout: self.collectionViewLayout)
    collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
    collectionView.backgroundColor = self.configuration.mainColor
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.layer.anchorPoint = CGPointMake(0.5, 0.5)

    return collectionView
    }()

  lazy var collectionViewLayout: UICollectionViewLayout = { [unowned self] in
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .Horizontal
    layout.minimumInteritemSpacing = self.configuration.cellSpacing
    layout.minimumLineSpacing = 2
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)

    return layout
    }()

  lazy var topSeparator: UIView = { [unowned self] in
    let view = UIView()
    view.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.addGestureRecognizer(self.panGestureRecognizer)
    view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)

    return view
    }()

  lazy var indicator: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.6)
    view.layer.cornerRadius = Dimensions.indicatorSize.height / 2
    view.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.frame.size = Dimensions.indicatorSize
    
    return view
    }()

  lazy var panGestureRecognizer: UIPanGestureRecognizer = { [unowned self] in
    let gesture = UIPanGestureRecognizer()
    gesture.addTarget(self, action: "handlePanGestureRecognizer:")

    return gesture
    }()

  lazy var selectedStack = ImageStack()

  lazy var images: NSMutableArray = {
    let images = NSMutableArray()
    return images
    }()

  lazy var configuration: PickerConfiguration = {
    let configuration = PickerConfiguration()
    return configuration
    }()

  lazy var noImagesLabel: UILabel = { [unowned self] in
    let label = UILabel()
    label.font = self.configuration.noImagesFont
    label.textColor = self.configuration.noImagesColor
    label.text = self.configuration.noImagesTitle
    label.alpha = 0
    label.sizeToFit()
    self.addSubview(label)
    
    return label
    }()

  weak var delegate: ImageGalleryPanGestureDelegate?
  var collectionSize: CGSize!
  var shouldTransform = false
  var imagesBeforeLoading = 0

  // MARK: - Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)

    collectionView.registerClass(ImageGalleryViewCell.self,
      forCellWithReuseIdentifier: CollectionView.reusableIdentifier)

    [collectionView, topSeparator].map { self.addSubview($0) }
    topSeparator.addSubview(indicator)

    imagesBeforeLoading = 0
    fetchPhotos(0)
  }

  required public init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Layout

  func updateFrames() {
    let totalWidth = UIScreen.mainScreen().bounds.width

    collectionView.dataSource = self
    collectionView.delegate = self

    topSeparator.frame = CGRect(x: 0, y: 0, width: totalWidth, height: Dimensions.galleryBarHeight)

    indicator.center = topSeparator.center

    collectionView.frame = CGRect(x: 0, y: topSeparator.frame.height, width: totalWidth, height: frame.height - topSeparator.frame.height)

    let height = max(collectionView.frame.height, 100)
    collectionSize = CGSize(width: height, height: height)
    
    noImagesLabel.center = collectionView.center
  }

  // MARK: - Photos handler

  func fetchPhotos(index: Int) {
    let imageManager = PHImageManager.defaultManager()

    let requestOptions = PHImageRequestOptions()
    requestOptions.synchronous = true

    let fetchOptions = PHFetchOptions()
    fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]

    let authorizationStatus = ALAssetsLibrary.authorizationStatus()

    let size = CGSizeMake(100, 150)

    if authorizationStatus == .Authorized {
      if let fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions) {
        if fetchResult.count != 0 && index < fetchResult.count {
          imageManager.requestImageForAsset(fetchResult.objectAtIndex(fetchResult.count - 1 - index) as! PHAsset, targetSize: size, contentMode: PHImageContentMode.AspectFill, options: requestOptions, resultHandler: { (image, _) in
            dispatch_async(dispatch_get_main_queue()) {
              if !self.images.containsObject(image) {
                self.images.addObject(image)
                if index > self.imagesBeforeLoading + 10 {
                  self.collectionView.reloadSections(NSIndexSet(index: 0))
                } else if index < fetchResult.count - 1 {
                  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    self.fetchPhotos(index+1)
                  }
                } else {
                  self.collectionView.reloadSections(NSIndexSet(index: 0))
                }
              }
            }
          })
        }
      }
    }
  }

  // MARK: - Pan gesture recognizer

  func handlePanGestureRecognizer(gesture: UIPanGestureRecognizer) {
    let translation = gesture.translationInView(superview!)
    let velocity = gesture.velocityInView(superview!)

    if gesture.state == UIGestureRecognizerState.Began {
      delegate?.panGestureDidStart()
    } else if gesture.state == UIGestureRecognizerState.Changed {
      delegate?.panGestureDidChange(translation)
    } else if gesture.state == UIGestureRecognizerState.Ended {
      delegate?.panGestureDidEnd(translation, velocity: velocity)
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

    if currentStatus == .NotDetermined {
      self.delegate?.hideViews()
    }

    PHPhotoLibrary.requestAuthorization { (authorizationStatus) -> Void in
      dispatch_async(dispatch_get_main_queue(), {
        if authorizationStatus == .Denied {
          let alertController = UIAlertController(title: "Permission denied", message: "Please, allow the application to access to your photo library.", preferredStyle: .Alert)

          let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { _ in
            let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString)
            UIApplication.sharedApplication().openURL(settingsURL!)
          })

          let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { _ in
            delegate?.dismissViewController(alertController)
          })

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
    let image = images[indexPath.row] as! UIImage

    if cell.selectedImageView.image != nil {
      UIView.animateWithDuration(0.2, animations: {
        cell.selectedImageView.transform = CGAffineTransformMakeScale(0.1, 0.1)
        }, completion: { _ in
          cell.selectedImageView.image = nil
      })
      selectedStack.dropImage(image)
    } else {
      cell.selectedImageView.image = getImage("selectedImageGallery")
      cell.selectedImageView.transform = CGAffineTransformMakeScale(0, 0)
      UIView.animateWithDuration(0.2, animations: { _ in
        cell.selectedImageView.transform = CGAffineTransformIdentity
      })
      selectedStack.pushImage(image)
    }
  }

  public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row + 10 >= images.count {
      imagesBeforeLoading = images.count
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        self.fetchPhotos(self.images.count)
      }
    }
  }
}
