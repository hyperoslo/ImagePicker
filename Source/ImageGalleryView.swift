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

  lazy var collectionViewLayout: UICollectionViewLayout = {
    let layout = UICollectionViewLayout()
    return layout
    }()

  lazy var topSeparator: UIView = {
    let view = UIView()
    view.setTranslatesAutoresizingMaskIntoConstraints(false)

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
    return gesture
    }()

  lazy var images: NSMutableArray = {
    let images = NSMutableArray()
    return images
    }()

  // MARK: - Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)

    [collectionView, topSeparator].map { self.addSubview($0) }
    topSeparator.addSubview(indicator)

    collectionView.dataSource = self
    collectionView.registerClass(ImageGalleryViewCell.classForCoder(), forCellWithReuseIdentifier: CollectionView.reusableIdentifier)

    setupConstraints()
    fetchPhotos(0)
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Layout

  func setupConstraints() {
    let attributes: [NSLayoutAttribute] = [.Top, .Right, .Width]

    attributes.map {
      self.addConstraint(NSLayoutConstraint(item: self.topSeparator, attribute: $0,
      relatedBy: .Equal, toItem: self, attribute: $0,
      multiplier: 1, constant: 0))
    }

    addConstraint(NSLayoutConstraint(item: topSeparator, attribute: .Height,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: Dimensions.galleryBarHeight))

    addConstraint(NSLayoutConstraint(item: indicator, attribute: .CenterX,
      relatedBy: .Equal, toItem: topSeparator, attribute: .CenterX,
      multiplier: 1, constant: 0))

    addConstraint(NSLayoutConstraint(item: indicator, attribute: .CenterY,
      relatedBy: .Equal, toItem: topSeparator, attribute: .CenterY,
      multiplier: 1, constant: 0))

    addConstraint(NSLayoutConstraint(item: indicator, attribute: .Width,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: Dimensions.indicatorWidth))

    addConstraint(NSLayoutConstraint(item: indicator, attribute: .Height,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: Dimensions.indicatorHeight))

    addConstraint(NSLayoutConstraint(item: collectionView, attribute: .Width,
      relatedBy: .Equal, toItem: self, attribute: .Width,
      multiplier: 1, constant: 0))

    addConstraint(NSLayoutConstraint(item: collectionView, attribute: .Height,
      relatedBy: .Equal, toItem: self, attribute: .Height,
      multiplier: 1, constant: -Dimensions.galleryBarHeight))

    addConstraint(NSLayoutConstraint(item: collectionView, attribute: .Top,
      relatedBy: .Equal, toItem: topSeparator, attribute: .Bottom,
      multiplier: 1, constant: 0))

    addConstraint(NSLayoutConstraint(item: collectionView, attribute: .CenterX,
      relatedBy: .Equal, toItem: self, attribute: .CenterX,
      multiplier: 1, constant: 0))

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
}
