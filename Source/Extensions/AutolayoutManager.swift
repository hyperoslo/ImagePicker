import UIKit

// MARK: - BottomContainer autolayout

extension BottomContainerView {

  func setupConstraints() {

    for attribute: NSLayoutAttribute in [.CenterX, .CenterY] {
      addConstraint(NSLayoutConstraint(item: pickerButton, attribute: attribute,
        relatedBy: .Equal, toItem: self, attribute: attribute,
        multiplier: 1, constant: 0))

      addConstraint(NSLayoutConstraint(item: borderPickerButton, attribute: attribute,
        relatedBy: .Equal, toItem: self, attribute: attribute,
        multiplier: 1, constant: 0))
    }

    for attribute: NSLayoutAttribute in [.Width, .Left, .Top] {
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

    for attribute: NSLayoutAttribute in [.Width, .Height] {
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
      multiplier: 1, constant: UIScreen.mainScreen().bounds.width/4 - ButtonPicker.Dimensions.buttonBorderSize/4))

    addConstraint(NSLayoutConstraint(item: topSeparator, attribute: .Height,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: 1))
  }
}

// MARK: - TopView autolayout

extension TopView {

  func setupConstraints() {
    addConstraint(NSLayoutConstraint(item: flashButton, attribute: .Left,
      relatedBy: .Equal, toItem: self, attribute: .Left,
      multiplier: 1, constant: Dimensions.leftOffset))

    addConstraint(NSLayoutConstraint(item: flashButton, attribute: .CenterY,
      relatedBy: .Equal, toItem: self, attribute: .CenterY,
      multiplier: 1, constant: 0))

    addConstraint(NSLayoutConstraint(item: flashButton, attribute: .Width,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: 55))

    addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .Right,
      relatedBy: .Equal, toItem: self, attribute: .Right,
      multiplier: 1, constant: -Dimensions.rightOffset))

    addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .CenterY,
      relatedBy: .Equal, toItem: self, attribute: .CenterY,
      multiplier: 1, constant: 0))
  }
}
