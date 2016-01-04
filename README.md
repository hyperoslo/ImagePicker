![ImagePicker](https://github.com/hyperoslo/ImagePicker/blob/master/Resources/ImagePickerPresentation.png)

[![Version](https://img.shields.io/cocoapods/v/ImagePicker.svg?style=flat)](http://cocoadocs.org/docsets/ImagePicker)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/ImagePicker.svg?style=flat)](http://cocoadocs.org/docsets/ImagePicker)
[![Platform](https://img.shields.io/cocoapods/p/ImagePicker.svg?style=flat)](http://cocoadocs.org/docsets/ImagePicker)

## Description

<img src="https://github.com/hyperoslo/ImagePicker/blob/master/Resources/ImagePickerIcon.png" alt="ImagePicker Icon" align="right" />
**ImagePicker** is an all-in-one camera solution for your iOS app. It let's your users select images from the library and take pictures at the same time. As a developer you get notified of all the user interactions and get the beautiful UI for free, out of the box, it's just that simple.

**ImagePicker** has been optimized to give a great user experience, it passes around referenced images instead of the image itself which makes it less memory consuming. This is what makes it smooth as butter.

## Usage

**ImagePicker** works as a normal controller, just instantiate it and present it.

```swift
let imagePickerController = ImagePickerController()
imagePickerController.delegate = self
presentViewController(imagePickerController, animated: true, completion: nil)
```

**ImagePicker** has three delegate methods that will inform you what the users are up to:

```swift
func wrapperDidPress(images: [UIImage])
func doneButtonDidPress(images: [UIImage])
func cancelButtonDidPress()
```

### Optional bonus

##### Configuration

Configure text, colors and fonts by just overriding the static variables in the ImagePicker [configuration](https://github.com/hyperoslo/ImagePicker/blob/master/Source/Configuration.swift) struct. As an example:

```swift
Configuration.doneButtonTitle = "Finish"
Configuration.noImagesTitle = "Sorry! There are no images here!"
```

##### Resolve assets

As said before, **ImagePicker** works with referenced images, that is really powerful because it lets you download the asset and choose the size you want. If you want to change the default implementation, just add a variable in your controller.

```swift
public var imageAssets: [UIImage] {
  return ImagePicker.resolveAssets(imagePicker.stack.assets)
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

[Hyper](http://hyper.no) made this with ❤️. If you’re using this library we probably want to [hire you](https://github.com/hyperoslo/iOS-playbook/blob/master/HYPER_RECIPES.md)! Send us an email at ios@hyper.no.

## Contribute

We would love you to contribute to **ImagePicker**, check the [CONTRIBUTING](https://github.com/hyperoslo/ImagePicker/blob/master/CONTRIBUTING.md) file for more info.

## License

**ImagePicker** is available under the MIT license. See the [LICENSE](https://github.com/hyperoslo/ImagePicker/blob/master/LICENSE.md) file for more info.
