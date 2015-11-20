# ImagePicker :camera:

[![Version](https://img.shields.io/cocoapods/v/ImagePicker.svg?style=flat)](http://cocoadocs.org/docsets/ImagePicker)
[![License](https://img.shields.io/cocoapods/l/ImagePicker.svg?style=flat)](http://cocoadocs.org/docsets/ImagePicker)
[![Platform](https://img.shields.io/cocoapods/p/ImagePicker.svg?style=flat)](http://cocoadocs.org/docsets/ImagePicker)

## Description

![ImagePicker](https://github.com/hyperoslo/ImagePicker/blob/master/Resources/ImagePickerPresentation.png)

**ImagePicker** is an all-in-one camera solution for your iOS app. It let's your users select images from the library and take pictures at the same time. As a developer you get notified of all the user interactions and get the beautiful UI for free, out of the box, it's just that simple.

**ImagePicker** has been optimized to give a great user experience, it passes around referenced images instead of the image itself which makes it less memory consuming. This is what makes it smooth as butter.

## Usage

**ImagePicker** works as a normal controller, just instantiate it and present it.

```swift
let imagePickerController = ImagePickerController()
presentViewController(imagePickerController, animated: true, completion: nil)
```

**ImagePicker** has three delegate methods that will inform you what the users are up to:

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
