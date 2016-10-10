import UIKit
import Photos

protocol ImageGalleryPanGestureDelegate: class {

  func panGestureDidStart()
  func panGestureDidChange(translation: CGPoint)
  func panGestureDidEnd(translation: CGPoint, velocity: CGPoint)
}

public class ImageGalleryView: UIView {

  struct Dimensions {
    static let galleryHeight: CGFloat = 160
    static let galleryBarHeight: CGFloat = 24
  }

  lazy public var collectionView: UICollectionView = { [unowned self] in
    let collectionView = UICollectionView(frame: CGRect.zero,
      collectionViewLayout: self.collectionViewLayout)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.backgroundColor = Configuration.mainColor
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.dataSource = self
    collectionView.delegate = self

    return collectionView
    }()

  lazy var collectionViewLayout: UICollectionViewLayout = { [unowned self] in
    let layout = ImageGalleryLayout()
    layout.scrollDirection = .Horizontal
    layout.minimumInteritemSpacing = Configuration.cellSpacing
    layout.minimumLineSpacing = 2
    layout.sectionInset = UIEdgeInsetsZero

    return layout
    }()

  lazy var topSeparator: UIView = { [unowned self] in
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.addGestureRecognizer(self.panGestureRecognizer)
    view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)

    return view
    }()

  lazy var panGestureRecognizer: UIPanGestureRecognizer = { [unowned self] in
    let gesture = UIPanGestureRecognizer()
    gesture.addTarget(self, action: #selector(handlePanGestureRecognizer(_:)))

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

    topSeparator.addSubview(Configuration.indicatorView)

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
    frame.size.width = totalWidth
    let collectionFrame = frame.height == Dimensions.galleryBarHeight ? 100 + Dimensions.galleryBarHeight : frame.height
    topSeparator.frame = CGRect(x: 0, y: 0, width: totalWidth, height: Dimensions.galleryBarHeight)
    topSeparator.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleWidth]
    Configuration.indicatorView.frame = CGRect(x: (totalWidth - Configuration.indicatorWidth) / 2, y: (topSeparator.frame.height - Configuration.indicatorHeight) / 2,
      width: Configuration.indicatorWidth, height: Configuration.indicatorHeight)
    collectionView.frame = CGRect(x: 0, y: topSeparator.frame.height, width: totalWidth, height: collectionFrame - topSeparator.frame.height)
    collectionSize = CGSize(width: collectionView.frame.height, height: collectionView.frame.height)

    collectionView.reloadData()
  }

  func updateNoImagesLabel() {
    let height = bounds.height
    let threshold = Dimensions.galleryBarHeight * 2

    UIView.animateWithDuration(0.25) {
      if threshold > height || self.collectionView.alpha != 0 {
        self.noImagesLabel.alpha = 0
      } else {
        self.noImagesLabel.center = CGPoint(x: self.bounds.width / 2, y: height / 2)
        self.noImagesLabel.alpha = (height > threshold) ? 1 : (height - Dimensions.galleryBarHeight) / threshold
      }
    }
  }

  // MARK: - Photos handler

  func fetchPhotos(completion: (() -> Void)? = nil) {
    AssetManager.fetch { assets in
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

  func displayNoImagesMessage(hideCollectionView: Bool) {
    collectionView.alpha = hideCollectionView ? 0 : 1
    updateNoImagesLabel()
  }
}

// MARK: CollectionViewFlowLayout delegate methods

extension ImageGalleryView: UICollectionViewDelegateFlowLayout {

  public func collectionView(collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
      guard let collectionSize = collectionSize else { return CGSize.zero }

      return collectionSize
  }
}

// MARK: CollectionView delegate methods

extension ImageGalleryView: UICollectionViewDelegate {

  public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    guard let cell = collectionView.cellForItemAtIndexPath(indexPath)
      as? ImageGalleryViewCell else { return }
    
    let asset = assets[indexPath.row]
    
    if cell.selectedImageView.image != nil {
      UIView.animateWithDuration(0.2, animations: {
        cell.selectedImageView.transform = CGAffineTransformMakeScale(0.1, 0.1)
      }) { _ in
        cell.selectedImageView.image = nil
      }
      self.selectedStack.dropAsset(asset)
    } else if self.imageLimit == 0 || self.imageLimit > self.selectedStack.assets.count {
      cell.selectedImageView.image = AssetManager.getImage("selectedImageGallery")
      cell.selectedImageView.transform = CGAffineTransformMakeScale(0, 0)
      UIView.animateWithDuration(0.2) { _ in
        cell.selectedImageView.transform = CGAffineTransformIdentity
      }
      self.selectedStack.pushAsset(asset)
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
