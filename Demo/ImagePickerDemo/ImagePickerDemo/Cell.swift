//
//  Cell.swift
//  ImagePickerDemo
//
//  Created by Khoa Pham on 11/8/15.
//  Copyright © 2015 Ramon Gilabert Llop. All rights reserved.
//

import Foundation
import UIKit

class Cell : UICollectionViewCell {
    @IBOutlet weak var hyperImageView: UIImageView!

    func configure(image image: UIImage) {
        hyperImageView.image = image
    }
}