import UIKit

// MARK: - BottomContainer autolayout

extension BottomContainerView {

  func setupConstraints(compactHeight: Bool) {
    removeConstraints(constraints)
    setupCommonConstraints()
    if compactHeight {
      setupCompactHeightConstraints()
    } else {
      setupRegularHeightConstraints()
    }
  }

  func setupCommonConstraints() {
    for attribute: NSLayoutAttribute in [.CenterX, .CenterY] {
      addConstraint(NSLayoutConstraint(item: pickerButton, attribute: attribute,
        relatedBy: .Equal, toItem: self, attribute: attribute,
        multiplier: 1, constant: 0))

      addConstraint(NSLayoutConstraint(item: borderPickerButton, attribute: attribute,
        relatedBy: .Equal, toItem: self, attribute: attribute,
        multiplier: 1, constant: 0))
    }

    for attribute: NSLayoutAttribute in [.Width, .Height] {
      addConstraint(NSLayoutConstraint(item: pickerButton, attribute: attribute,
        relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
        multiplier: 1, constant: ButtonPicker.Dimensions.buttonSize))

      addConstraint(NSLayoutConstraint(item: borderPickerButton, attribute: attribute,
        relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
        multiplier: 1, constant: ButtonPicker.Dimensions.buttonBorderSize))

      addConstraint(NSLayoutConstraint(item: stackView, attribute: attribute,
        relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
        multiplier: 1, constant: ImageStackView.Dimensions.imageSize))
    }
  }

  func setupRegularHeightConstraints() {
    for attribute: NSLayoutAttribute in [.Width, .Left, .Top] {
      addConstraint(NSLayoutConstraint(item: topSeparator, attribute: attribute,
        relatedBy: .Equal, toItem: self, attribute: attribute,
        multiplier: 1, constant: 0))
    }

    addConstraint(NSLayoutConstraint(item: doneButton, attribute: .CenterY,
      relatedBy: .Equal, toItem: self, attribute: .CenterY,
      multiplier: 1, constant: 0))

    addConstraint(NSLayoutConstraint(item: stackView, attribute: .CenterY,
      relatedBy: .Equal, toItem: self, attribute: .CenterY,
      multiplier: 1, constant: -2))

    addConstraint(NSLayoutConstraint(item: doneButton, attribute: .CenterX,
      relatedBy: .Equal, toItem: self, attribute: .Right,
      multiplier: 1, constant: -(UIScreen.mainScreen().bounds.width - (ButtonPicker.Dimensions.buttonBorderSize + UIScreen.mainScreen().bounds.width)/2)/2))

    addConstraint(NSLayoutConstraint(item: stackView, attribute: .CenterX,
      relatedBy: .Equal, toItem: self, attribute: .Left,
      multiplier: 1, constant: UIScreen.mainScreen().bounds.width/4 - ButtonPicker.Dimensions.buttonBorderSize/3))

    addConstraint(NSLayoutConstraint(item: topSeparator, attribute: .Height,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: 1))

  }

  func setupCompactHeightConstraints() {
    for attribute: NSLayoutAttribute in [.Height, .Left, .Top] {
      addConstraint(NSLayoutConstraint(item: topSeparator, attribute: attribute,
        relatedBy: .Equal, toItem: self, attribute: attribute,
        multiplier: 1, constant: 0))
    }

    addConstraint(NSLayoutConstraint(item: doneButton, attribute: .CenterX,
      relatedBy: .Equal, toItem: self, attribute: .CenterX,
      multiplier: 1, constant: 0))

    addConstraint(NSLayoutConstraint(item: stackView, attribute: .CenterX,
      relatedBy: .Equal, toItem: self, attribute: .CenterX,
      multiplier: 1, constant: -2))

    addConstraint(NSLayoutConstraint(item: doneButton, attribute: .CenterY,
      relatedBy: .Equal, toItem: self, attribute: .Bottom,
      multiplier: 1, constant: -(UIScreen.mainScreen().bounds.height - (ButtonPicker.Dimensions.buttonBorderSize + UIScreen.mainScreen().bounds.height)/2)/2))

    addConstraint(NSLayoutConstraint(item: stackView, attribute: .CenterY,
      relatedBy: .Equal, toItem: self, attribute: .Top,
      multiplier: 1, constant: UIScreen.mainScreen().bounds.height/4 - ButtonPicker.Dimensions.buttonBorderSize/3))

    addConstraint(NSLayoutConstraint(item: topSeparator, attribute: .Width,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: 1))
  }
}

// MARK: - TopView autolayout

extension TopView {

  func setupConstraints(compactHeight: Bool) {
    removeConstraints(constraints)
    setupCommonConstraints()
    if compactHeight {
      setupCompactHeightConstraints()
    } else {
      setupRegularHeightConstraints()
    }
  }

  func setupCommonConstraints() {
    addConstraint(NSLayoutConstraint(item: flashButton, attribute: .Width,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: 55))

    if Configuration.canRotateCamera {
      addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .Width,
        relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
        multiplier: 1, constant: 55))

      addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .Height,
        relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
        multiplier: 1, constant: 55))
    }

  }

  func setupCompactHeightConstraints() {
    addConstraint(NSLayoutConstraint(item: flashButton, attribute: .Left,
      relatedBy: .Equal, toItem: self, attribute: .Left,
      multiplier: 1, constant: 8))

    addConstraint(NSLayoutConstraint(item: flashButton, attribute: .Top,
      relatedBy: .Equal, toItem: self, attribute: .Top,
      multiplier: 1, constant: 6))

    if Configuration.canRotateCamera {
      addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .Bottom,
        relatedBy: .Equal, toItem: self, attribute: .Bottom,
        multiplier: 1, constant: Dimensions.rightOffset))

      addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .CenterX,
        relatedBy: .Equal, toItem: self, attribute: .CenterX,
        multiplier: 1, constant: 0))

    }

  }

  func setupRegularHeightConstraints() {
    addConstraint(NSLayoutConstraint(item: flashButton, attribute: .Left,
      relatedBy: .Equal, toItem: self, attribute: .Left,
      multiplier: 1, constant: Dimensions.leftOffset))

    addConstraint(NSLayoutConstraint(item: flashButton, attribute: .CenterY,
      relatedBy: .Equal, toItem: self, attribute: .CenterY,
      multiplier: 1, constant: 0))

    if Configuration.canRotateCamera {
      addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .Right,
        relatedBy: .Equal, toItem: self, attribute: .Right,
        multiplier: 1, constant: Dimensions.rightOffset))

      addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .CenterY,
        relatedBy: .Equal, toItem: self, attribute: .CenterY,
        multiplier: 1, constant: 0))
    }
  }
}

// MARK: - Controller autolayout

extension ImagePickerController {

  func setupConstraints(compactHeight: Bool) {
    view.constraints.forEach() { constraint in
      if constraint.firstItem as! NSObject == cameraController.view ||
        constraint.firstItem as! NSObject == bottomContainer ||
        constraint.firstItem as! NSObject == topView
      {
        view.removeConstraint(constraint)
      }
    }
    if compactHeight {
      setupCompactHeightConstraints()
    } else {
      setupRegularHeightConstraints()
    }
  }

  func setupRegularHeightConstraints() {
    for attribute: NSLayoutAttribute in [.Left, .Top, .Width] {
      view.addConstraint(NSLayoutConstraint(item: cameraController.view, attribute: attribute,
        relatedBy: .Equal, toItem: view, attribute: attribute,
        multiplier: 1, constant: 0))
    }

    view.addConstraint(NSLayoutConstraint(item: cameraController.view, attribute: .Height,
      relatedBy: .Equal, toItem: view, attribute: .Height,
      multiplier: 1, constant: -BottomContainerView.Dimensions.height))

    for attribute: NSLayoutAttribute in [.Bottom, .Right, .Width] {
      view.addConstraint(NSLayoutConstraint(item: bottomContainer, attribute: attribute,
        relatedBy: .Equal, toItem: view, attribute: attribute,
        multiplier: 1, constant: 0))
    }

    view.addConstraint(NSLayoutConstraint(item: bottomContainer, attribute: .Height,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: BottomContainerView.Dimensions.height))

    for attribute: NSLayoutAttribute in [.Left, .Top, .Width] {
      view.addConstraint(NSLayoutConstraint(item: topView, attribute: attribute,
        relatedBy: .Equal, toItem: self.view, attribute: attribute,
        multiplier: 1, constant: 0))
    }

    view.addConstraint(NSLayoutConstraint(item: topView, attribute: .Height,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: TopView.Dimensions.height))

  }

  func setupCompactHeightConstraints() {

    for attribute: NSLayoutAttribute in [.Left, .Top, .Height] {
      view.addConstraint(NSLayoutConstraint(item: cameraController.view, attribute: attribute,
        relatedBy: .Equal, toItem: view, attribute: attribute,
        multiplier: 1, constant: 0))
    }

    view.addConstraint(NSLayoutConstraint(item: cameraController.view, attribute: .Width,
      relatedBy: .Equal, toItem: view, attribute: .Width,
      multiplier: 1, constant: -BottomContainerView.Dimensions.height))

    for attribute: NSLayoutAttribute in [.Top, .Right, .Height] {
      view.addConstraint(NSLayoutConstraint(item: bottomContainer, attribute: attribute,
        relatedBy: .Equal, toItem: view, attribute: attribute,
        multiplier: 1, constant: 0))
    }

    view.addConstraint(NSLayoutConstraint(item: bottomContainer, attribute: .Width,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: BottomContainerView.Dimensions.height))

    for attribute: NSLayoutAttribute in [.Left, .Top, .Height] {
      view.addConstraint(NSLayoutConstraint(item: topView, attribute: attribute,
        relatedBy: .Equal, toItem: self.view, attribute: attribute,
        multiplier: 1, constant: 0))
    }

    view.addConstraint(NSLayoutConstraint(item: topView, attribute: .Width,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: TopView.Dimensions.height))
  }

}

extension ImageGalleryViewCell {

  func setupConstraints() {

    for attribute: NSLayoutAttribute in [.Width, .Height, .CenterX, .CenterY] {
      addConstraint(NSLayoutConstraint(item: imageView, attribute: attribute,
        relatedBy: .Equal, toItem: self, attribute: attribute,
        multiplier: 1, constant: 0))

      addConstraint(NSLayoutConstraint(item: selectedImageView, attribute: attribute,
        relatedBy: .Equal, toItem: self, attribute: attribute,
        multiplier: 1, constant: 0))
    }
  }
}

extension ButtonPicker {

  func setupConstraints() {
    let attributes: [NSLayoutAttribute] = [.CenterX, .CenterY]

    for attribute in attributes {
      addConstraint(NSLayoutConstraint(item: numberLabel, attribute: attribute,
        relatedBy: .Equal, toItem: self, attribute: attribute,
        multiplier: 1, constant: 0))
    }
  }
}
