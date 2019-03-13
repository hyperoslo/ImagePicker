⚠️ DEPRECATED, NO LONGER MAINTAINED

![ImagePicker](https://github.com/hyperoslo/ImagePicker/blob/master/Resources/ImagePickerPresentation.png)

[![Version](https://img.shields.io/cocoapods/v/ImagePicker.svg?style=flat)](http://cocoadocs.org/docsets/ImagePicker)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/ImagePicker.svg?style=flat)](http://cocoadocs.org/docsets/ImagePicker)
[![Platform](https://img.shields.io/cocoapods/p/ImagePicker.svg?style=flat)](http://cocoadocs.org/docsets/ImagePicker)
![Swift](https://img.shields.io/badge/%20in-swift%204.0-orange.svg)
[![Join the chat at https://gitter.im/hyperoslo/ImagePicker](https://badges.gitter.im/hyperoslo/ImagePicker.svg)](https://gitter.im/hyperoslo/ImagePicker?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## Description

<img src="https://github.com/hyperoslo/ImagePicker/blob/master/Resources/ImagePickerIcon.png" alt="ImagePicker Icon" align="right" />

**ImagePicker** is an all-in-one camera solution for your iOS app. It lets your users select images from the library and take pictures at the same time. As a developer you get notified of all the user interactions and get the beautiful UI for free, out of the box, it's just that simple.

**ImagePicker** has been optimized to give a great user experience, it passes around referenced images instead of the image itself which makes it less memory consuming. This is what makes it smooth as butter.

## Usage

**ImagePicker** works as a normal controller, just instantiate it and present it.

```swift
let imagePickerController = ImagePickerController()
imagePickerController.delegate = self
present(imagePickerController, animated: true, completion: nil)
```

**ImagePicker** has three delegate methods that will inform you what the users are up to:

```swift
func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage])
func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage])
func cancelButtonDidPress(_ imagePicker: ImagePickerController)
```

**ImagePicker** supports limiting the amount of images that can be selected, it defaults
to zero, which means that the user can select as many images as he/she wants.

```swift
let imagePickerController = ImagePickerController()
imagePickerController.imageLimit = 5
```

### Optional bonus

##### Configuration

You can inject `Configuration` instance to ImagePicker, which allows you to configure text, colors, fonts and camera features

```swift
var configuration = Configuration()
configuration.doneButtonTitle = "Finish"
configuration.noImagesTitle = "Sorry! There are no images here!"
configuration.recordLocation = false

let imagePicker = ImagePickerController(configuration: configuration)
```

##### Resolve assets

As said before, **ImagePicker** works with referenced images, that is really powerful because it lets you download the asset and choose the size you want. If you want to change the default implementation, just add a variable in your controller.

```swift
public var imageAssets: [UIImage] {
  return AssetManager.resolveAssets(imagePicker.stack.assets)
}
```

And when you call any delegate method that returns images, add in the first line:

```swift
let images = imageAssets
```

## Installation

**ImagePicker** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ImagePicker'
```

**ImagePicker** is also available through [Carthage](https://github.com/Carthage/Carthage).
To install just write into your Cartfile:

```ruby
github "hyperoslo/ImagePicker"
```

## Author

[Hyper](http://hyper.no) made this with ❤️

## Contribute

We would love you to contribute to **ImagePicker**, check the [CONTRIBUTING](https://github.com/hyperoslo/ImagePicker/blob/master/CONTRIBUTING.md) file for more info.

## License

**ImagePicker** is available under the MIT license. See the [LICENSE](https://github.com/hyperoslo/ImagePicker/blob/master/LICENSE.md) file for more info.
