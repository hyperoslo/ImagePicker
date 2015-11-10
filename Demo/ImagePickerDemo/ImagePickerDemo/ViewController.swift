import Foundation
import UIKit
import ImagePicker

class ViewController : UICollectionViewController, ImagePickerDelegate, UICollectionViewDelegateFlowLayout {
  var images = [UIImage]()

  // MARK: UICollectionViewDataSource

  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return images.count
  }

  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! Cell
    let image = images[indexPath.item]
    cell.configure(image: image)

    return cell
  }

  // MARK: UICollectionViewDelegateFlowLayout

  func collectionView(collectionView: UICollectionView, layout
    collectionViewLayout: UICollectionViewLayout,
    sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

      let size = CGRectGetWidth(collectionView.bounds)
      return CGSize(width: size, height: size)
  }

  // MARK: ImagePickerDelegate

  func imagePicker(imagePickerController: ImagePickerController, doneButtonDidPress images: [UIImage]) {
    self.images = images
    collectionView?.reloadData()
    imagePickerController.dismissViewControllerAnimated(true, completion: nil)
  }

  // MARK: Action
    
  @IBAction func selectButtonTouched(sender: UIBarButtonItem) {
    let imagePicker = ImagePickerController()
    imagePicker.delegate = self

    presentViewController(imagePicker, animated: true, completion: nil)
  }
}
