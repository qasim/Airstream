# Airstream

Airstream is an iOS / macOS framework for streaming audio between Apple devices using AirPlay.

[ An example gif ]

You can use Airstream to start an AirPlay server in your iOS or macOS applications. Then, any Apple device can stream audio to your application via AirPlay, with no extra software required.

## Installation

Airstream can be installed by using either CocoaPods, Carthage, or just simply cloning this repository and its submodules in your project.

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

You can install it using [Homebrew](http://brew.sh/) with the following commands:

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
$ carthage
```

Drag the built `Airstream.framework` into your Xcode project.

## Basic usage

First, initialize and start Airstream somewhere (make sure that it's retained). You'll also want to set its delegate.

```swift
let airstream = Airstream(name: "My Airstream")

airstream.delegate = self
airstream.startServer()
```

That's it! Your own AirPlay server is now up and running. You can gracefully shut it down as well:

```swift
airstream.stopServer()
```

Implement any of the delegate methods to actually make use of Airstream's features, like retrieving a song's album artwork:

```swift
func airstream(airstream: Airstream, didSetCoverart coverart: NSData) {
  // Coverart for the item that's currently streaming
  let image = NSImage(data: coverart)
}
```

## API reference

### Airstream

```swift
var name: String
```

Description goes here.

-

```swift
var password: String?
```

Description goes here.

-

```swift
var port: Int
```

Description goes here.

-

```swift
var running: Bool
```

Description goes here.

-

```swift
func init()
```

Description goes here.

-

```swift
func startServer()
```

Description goes here.

-

```swift
var remote: AirstreamRemote?
```

Description goes here.

-

```swift
var volume: Float?
```

Description goes here.

-

```swift
var metadata: [String: String]?
```

Description goes here.

-

```swift
var coverart: NSData?
```

Description goes here.

-

```swift
var position: Int?
```

Description goes here.

-

```swift
var duration: Int?
```

Description goes here.

### AirstreamRemote

### AirstreamDelegate

## Shairplay

Airstream works by depending on a C library called [shairplay](https://github.com/juhovh/shairplay), which is a free portable AirPlay server implementation. You can also visit [qasim/shairplay](https://github.com/qasim/shairplay) for the fork of shairplay that is used by Airstream, which compiles on both iOS and macOS.

## License

Airstream is released under the MIT license. See [LICENSE](./LICENSE) for details.
