import UIKit
import Photos

class ImageGalleryView: UIView {

  struct Dimensions {
    static let galleryHeight: CGFloat = 160
    static let galleryBarHeight: CGFloat = 34
    static let indicatorWidth: CGFloat = 41
    static let indicatorHeight: CGFloat = 8
  }

  lazy var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: CGRectMake(0, 0, 0, 0),
      collectionViewLayout: self.collectionViewLayout)
    collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)

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
    view.backgroundColor = self.configuration.backgroundColor

    return view
    }()

  lazy var indicator: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(red:0.36, green:0.39, blue:0.42, alpha:1)
    view.layer.cornerRadius = Dimensions.indicatorHeight / 2
    view.setTranslatesAutoresizingMaskIntoConstraints(false)
    
    return view
    }()

  lazy var panGestureRecognizer: UIPanGestureRecognizer = {
    let gesture = UIPanGestureRecognizer()
    gesture.addTarget(self, action: "handlePanGestureRecognizer:")

    return gesture
    }()

  lazy var images: NSMutableArray = {
    let images = NSMutableArray()
    return images
    }()

  lazy var configuration: PickerConfiguration = {
    let configuration = PickerConfiguration()
    return configuration
    }()

  var topSeparatorCenter: CGPoint!
  var collectionSize: CGSize!
  var initialFrame: CGRect!

  // MARK: - Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)

    collectionView.registerClass(ImageGalleryViewCell.self,
      forCellWithReuseIdentifier: CollectionView.reusableIdentifier)

    [collectionView, topSeparator].map { self.addSubview($0) }
    topSeparator.addSubview(indicator)

    fetchPhotos(0)
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Layout

  func updateFrames() {
    collectionView.dataSource = self
    collectionView.delegate = self

    topSeparator.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, Dimensions.galleryBarHeight)
    indicator.frame = CGRectMake(UIScreen.mainScreen().bounds.width / 2 - Dimensions.indicatorWidth / 2, topSeparator.frame.height / 2 - Dimensions.indicatorHeight / 2, Dimensions.indicatorWidth, Dimensions.indicatorHeight)
    indicator.frame.size = CGSizeMake(Dimensions.indicatorWidth, Dimensions.indicatorHeight)
    collectionView.frame = CGRectMake(0, topSeparator.frame.height, UIScreen.mainScreen().bounds.width, frame.height - topSeparator.frame.height)
    collectionSize = CGSizeMake(frame.height - topSeparator.frame.height, frame.height - topSeparator.frame.height)
  }

  // MARK: - Photos handler

  func fetchPhotos(index: Int) {
    let imageManager = PHImageManager.defaultManager()

    let requestOptions = PHImageRequestOptions()
    requestOptions.synchronous = true

    let fetchOptions = PHFetchOptions()
    fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]

    let size = CGSizeMake(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - 150)

    if let fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions) {
      imageManager.requestImageForAsset(fetchResult.objectAtIndex(fetchResult.count - 1 - index) as! PHAsset, targetSize: size, contentMode: PHImageContentMode.AspectFill, options: requestOptions, resultHandler: { (image, _) in
        self.images.addObject(image)
        if index < 3 {
          self.fetchPhotos(index+1)
        }
      })
    }

    if index == 3 {
      collectionView.reloadData()
    }
  }

  // MARK: - Pan gesture recognizer

  func handlePanGestureRecognizer(gesture: UIPanGestureRecognizer) {
    let translation = gesture.translationInView(superview!)
    let location = gesture.locationInView(superview!)
    let velocity = gesture.velocityInView(superview!)

    if gesture.state == UIGestureRecognizerState.Began {
      topSeparatorCenter = topSeparator.center
      initialFrame = frame
    } else if gesture.state == UIGestureRecognizerState.Changed {
      frame.size.height = initialFrame.height - translation.y
      frame.origin.y = initialFrame.origin.y + translation.y
      topSeparator.frame.origin.y = 0

      if frame.size.height - topSeparator.frame.height > 100 {
        collectionViewLayout.invalidateLayout()
        collectionView.frame.size.height = frame.size.height - topSeparator.frame.height
        collectionSize = CGSizeMake(frame.size.height - topSeparator.frame.height, frame.size.height - topSeparator.frame.height)
        collectionView.reloadData()
      } else {
        collectionView.frame.origin.y = topSeparator.frame.height
      }

      if location.y - 25 >= initialFrame.origin.y + initialFrame.height - topSeparator.frame.height {
        frame.size.height = topSeparator.frame.height
        frame.origin.y = initialFrame.origin.y + initialFrame.height - topSeparator.frame.height
      } else if collectionView.frame.height >= Dimensions.galleryHeight {
        frame.size.height = Dimensions.galleryHeight + topSeparator.frame.height
        frame.origin.y = initialFrame.origin.y + initialFrame.height - topSeparator.frame.height - Dimensions.galleryHeight
        collectionView.frame.size.height = Dimensions.galleryHeight
        collectionSize = CGSizeMake(collectionView.frame.height, collectionView.frame.height)
        collectionView.reloadData()
      }
    } else if gesture.state == UIGestureRecognizerState.Ended {
      if velocity.y < -100 {
        UIView.animateWithDuration(0.2, animations: { [unowned self] in
          self.frame.size.height = Dimensions.galleryHeight + self.topSeparator.frame.height
          self.frame.origin.y = self.initialFrame.origin.y + self.initialFrame.height - self.topSeparator.frame.height - Dimensions.galleryHeight
          self.collectionViewLayout.invalidateLayout()
          self.collectionView.frame.size.height = Dimensions.galleryHeight
          self.collectionSize = CGSizeMake(self.collectionView.frame.height, self.collectionView.frame.height)
          }, completion: { finished in
            self.collectionView.reloadData()
        })
      } else if velocity.y > 100 || frame.size.height - topSeparator.frame.height < 100 {
        UIView.animateWithDuration(0.2, animations: { [unowned self] in
          self.frame.size.height = self.topSeparator.frame.height
          self.frame.origin.y = self.initialFrame.origin.y + self.initialFrame.height - self.topSeparator.frame.height
          self.collectionViewLayout.invalidateLayout()
          self.collectionView.frame.size.height = 100
          self.collectionSize = CGSizeMake(self.collectionView.frame.height, self.collectionView.frame.height)
          }, completion: { finished in
            self.collectionView.reloadData()
        })
      }
    }
  }
}

extension ImageGalleryView: UICollectionViewDelegateFlowLayout {

  func collectionView(collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
      return collectionSize
  }
}
