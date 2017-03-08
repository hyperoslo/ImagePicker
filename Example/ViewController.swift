//
//  ViewController.swift
//  Example
//
//  Created by Erick Vavretchek on 7/3/17.
//  Copyright © 2017 Hyper Interaktiv AS. All rights reserved.
//

import UIKit
import ImagePicker

class ViewController: UIViewController {
  
  var imagePickerController: ImagePickerController?
  
  @IBAction func clicked(sender: AnyObject) {
    imagePickerController = ImagePickerController()
    if let ip = self.imagePickerController {
      ip.delegate = self
      ip.imageLimit = 5
      presentViewController(ip, animated: true, completion: nil)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }
}

extension ViewController: ImagePickerDelegate {
  func wrapperDidPress(imagePicker: ImagePickerController, images: [UIImage]) {}
  func cancelButtonDidPress(imagePicker: ImagePickerController) {}
  
  func doneButtonDidPress(imagePicker: ImagePickerController, images: [UIImage]) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
}

