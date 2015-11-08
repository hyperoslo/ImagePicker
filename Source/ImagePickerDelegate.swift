//
//  ImagePickerDelegate.swift
//  Pods
//
//  Created by Khoa Pham on 11/8/15.
//
//

import Foundation

public protocol ImagePickerDelegate: class {
  func imagePicker(imagePickerController: ImagePickerController, wrapperDidPress images: [UIImage])
  func imagePicker(imagePickerController: ImagePickerController, doneButtonDidPress images: [UIImage])
  func imagePickerCancelButtonDidPress(imagePickerController: ImagePickerController)
}

public extension ImagePickerDelegate {
  func imagePicker(imagePickerController: ImagePickerController, wrapperDidPress images: [UIImage]) {}
  func imagePickerCancelButtonDidPress(imagePickerController: ImagePickerController) {}
}