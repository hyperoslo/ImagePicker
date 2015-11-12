import Foundation
import UIKit

class Cell : UICollectionViewCell {
  @IBOutlet weak var hyperImageView: UIImageView!

  func configure(image image: UIImage) {
    hyperImageView.image = image
  }
}
