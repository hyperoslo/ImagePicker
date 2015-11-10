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
