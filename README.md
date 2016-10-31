# Airstream

Airstream is an iOS / macOS framework for streaming audio between Apple devices using AirPlay.

[ An example gif ]

You can use Airstream to start an AirPlay server in your iOS or macOS applications. Then, any Apple device can stream audio to your application via AirPlay, with no extra software required.

## Installation

Airstream can be installed by using either CocoaPods, Carthage, or just simply cloning this repository in your project.

### CocoaPods

[CocoaPods](https://cocoapods.org/) is a dependency manager for Swift and Objective-C Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

Then, to include Airstream in your project, specify it in your `Podfile`:

```ruby
target 'MyApp' do
  pod 'Airstream', '~> 0.1'
end
```

Now you can install Airstream into your Xcode project:

```bash
$ pod install
```

For more information, have a look at [Using CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html).

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager for Cocoa.

You can install it using [Homebrew]() with the following command:

```bash
$ brew update
$ brew install carthage
```

Then, to include Airstream in your project, specify it in your `Cartfile`:

```ruby
github "qasim/Airstream" ~> 0.1
```

Now you can install Airstream:

```bash
$ Carthage
```

Drag the built `Airstream.framework` into your Xcode project.

## Basic usage

Guide.

## API reference

`Airstream` and `AirstreamDelegate` class reference.

## Shairplay

Airstream works by depending on a C library called [shairplay](https://github.com/juhovh/shairplay), which is a free portable AirPlay server implementation. You can visit [qasim/shairplay](https://github.com/qasim/shairplay) for the fork of shairplay that is used by Airstream, which compiles on both iOS and macOS.

## License

Airstream is released under the MIT license. See [LICENSE](./LICENSE) for details.
