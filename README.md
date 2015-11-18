# ImagePicker :camera:

[![Version](https://img.shields.io/cocoapods/v/ImagePicker.svg?style=flat)](http://cocoadocs.org/docsets/ImagePicker)
[![License](https://img.shields.io/cocoapods/l/ImagePicker.svg?style=flat)](http://cocoadocs.org/docsets/ImagePicker)
[![Platform](https://img.shields.io/cocoapods/p/ImagePicker.svg?style=flat)](http://cocoadocs.org/docsets/ImagePicker)

## Description

![ImagePicker](https://github.com/hyperoslo/ImagePicker/master/Resources/ImagePickerPresentation.png)

**ImagePicker** is the all in one camera solution for your iOS app. Let your users select images from the library or take pictures at the same time with this component. Get notified of every event and get all the UI work for free.

The component has been optimize to give a great user experience for the library working with assets instead of referenced images, this allows it to create a fast and smooth infinite scrolling.

## Usage

**ImagePicker** works as a normal controller, just instantiate it and present it.

```swift
let imagePickerController = ImagePickerController()
presentViewController(imagePickerController, animated: true, completion: nil)
```

**ImagePicker** will let you know if the user interacts with it, we have some delegate methods:

```swift
func wrapperDidPress(images: [UIImage])
func doneButtonDidPress(images: [UIImage])
func cancelButtonDidPress()
```

## Installation

**ImagePicker** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ImagePicker'
```

## Author

Hyper Interaktiv AS, ios@hyper.no

## License

**ImagePicker** is available under the MIT license. See the LICENSE file for more info.
