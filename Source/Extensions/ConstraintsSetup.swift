import UIKit

// MARK: - BottomContainer autolayout

extension BottomContainerView {

  func setupConstraints() {

    for attribute: NSLayoutAttribute in [.CenterX, .CenterY] {
      NSLayoutConstraint(item: pickerButton, attribute: attribute,
        relatedBy: .Equal, toItem: self, attribute: attribute,
        multiplier: 1, constant: 0).active = true

      NSLayoutConstraint(item: borderPickerButton, attribute: attribute,
        relatedBy: .Equal, toItem: self, attribute: attribute,
        multiplier: 1, constant: 0).active = true
    }

    for attribute: NSLayoutAttribute in [.Width, .Left, .Top] {
      NSLayoutConstraint(item: topSeparator, attribute: attribute,
        relatedBy: .Equal, toItem: self, attribute: attribute,
        multiplier: 1, constant: 0).active = true
    }

    for attribute: NSLayoutAttribute in [.Width, .Height] {
      NSLayoutConstraint(item: pickerButton, attribute: attribute,
        relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
        multiplier: 1, constant: ButtonPicker.Dimensions.buttonSize).active = true

      NSLayoutConstraint(item: borderPickerButton, attribute: attribute,
        relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
        multiplier: 1, constant: ButtonPicker.Dimensions.buttonBorderSize).active = true

      NSLayoutConstraint(item: stackView, attribute: attribute,
        relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
        multiplier: 1, constant: ImageStackView.Dimensions.imageSize).active = true
    }

    NSLayoutConstraint(item: doneButton, attribute: .CenterY,
      relatedBy: .Equal, toItem: self, attribute: .CenterY,
      multiplier: 1, constant: 0).active = true

    NSLayoutConstraint(item: stackView, attribute: .CenterY,
      relatedBy: .Equal, toItem: self, attribute: .CenterY,
      multiplier: 1, constant: -2).active = true

    NSLayoutConstraint(item: doneButton, attribute: .CenterX,
      relatedBy: .Equal, toItem: self, attribute: .Right,
      multiplier: 1, constant: -(UIScreen.mainScreen().bounds.width - (ButtonPicker.Dimensions.buttonBorderSize + UIScreen.mainScreen().bounds.width)/2)/2)
      .active = true

    NSLayoutConstraint(item: stackView, attribute: .CenterX,
      relatedBy: .Equal, toItem: self, attribute: .Left,
      multiplier: 1, constant: UIScreen.mainScreen().bounds.width/4 - ButtonPicker.Dimensions.buttonBorderSize/3).active = true

    NSLayoutConstraint(item: topSeparator, attribute: .Height,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: 1).active = true
  }
}

// MARK: - TopView autolayout

extension TopView {

  func setupConstraints() {
    NSLayoutConstraint(item: flashButton, attribute: .Left,
      relatedBy: .Equal, toItem: self, attribute: .Left,
      multiplier: 1, constant: Dimensions.leftOffset).active = true

    NSLayoutConstraint(item: flashButton, attribute: .CenterY,
      relatedBy: .Equal, toItem: self, attribute: .CenterY,
      multiplier: 1, constant: 0).active = true

    NSLayoutConstraint(item: flashButton, attribute: .Width,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: 55).active = true

    if Configuration.canRotateCamera {
      NSLayoutConstraint(item: rotateCamera, attribute: .Right,
        relatedBy: .Equal, toItem: self, attribute: .Right,
        multiplier: 1, constant: Dimensions.rightOffset).active = true

      NSLayoutConstraint(item: rotateCamera, attribute: .CenterY,
        relatedBy: .Equal, toItem: self, attribute: .CenterY,
        multiplier: 1, constant: 0).active = true

      NSLayoutConstraint(item: rotateCamera, attribute: .Width,
        relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
        multiplier: 1, constant: 55).active = true

      NSLayoutConstraint(item: rotateCamera, attribute: .Height,
        relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
        multiplier: 1, constant: 55).active = true
    }
  }
}

// MARK: - Controller autolayout

extension ImagePickerController {

  func setupConstraints() {
    let attributes: [NSLayoutAttribute] = [.Bottom, .Right, .Width]
    let topViewAttributes: [NSLayoutAttribute] = [.Left, .Top, .Width]

    for attribute in attributes {
      NSLayoutConstraint(item: bottomContainer, attribute: attribute,
        relatedBy: .Equal, toItem: view, attribute: attribute,
        multiplier: 1, constant: 0).active = true
    }

    for attribute: NSLayoutAttribute in [.Left, .Top, .Width] {
      NSLayoutConstraint(item: cameraController.view, attribute: attribute,
        relatedBy: .Equal, toItem: view, attribute: attribute,
        multiplier: 1, constant: 0).active = true
    }

    for attribute in topViewAttributes {
      NSLayoutConstraint(item: topView, attribute: attribute,
        relatedBy: .Equal, toItem: self.view, attribute: attribute,
        multiplier: 1, constant: 0).active = true
    }

    NSLayoutConstraint(item: bottomContainer, attribute: .Height,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: BottomContainerView.Dimensions.height).active = true

    NSLayoutConstraint(item: topView, attribute: .Height,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: TopView.Dimensions.height).active = true

    NSLayoutConstraint(item: cameraController.view, attribute: .Height,
      relatedBy: .Equal, toItem: view, attribute: .Height,
      multiplier: 1, constant: -BottomContainerView.Dimensions.height).active = true
  }
}

extension ImageGalleryViewCell {

  func setupConstraints() {

    for attribute: NSLayoutAttribute in [.Width, .Height, .CenterX, .CenterY] {
      NSLayoutConstraint(item: imageView, attribute: attribute,
        relatedBy: .Equal, toItem: self, attribute: attribute,
        multiplier: 1, constant: 0).active = true

      NSLayoutConstraint(item: selectedImageView, attribute: attribute,
        relatedBy: .Equal, toItem: self, attribute: attribute,
        multiplier: 1, constant: 0).active = true
    }
  }
}

extension ButtonPicker {

  func setupConstraints() {
    let attributes: [NSLayoutAttribute] = [.CenterX, .CenterY]

    for attribute in attributes {
      NSLayoutConstraint(item: numberLabel, attribute: attribute,
        relatedBy: .Equal, toItem: self, attribute: attribute,
        multiplier: 1, constant: 0).active = true
    }
  }
}
