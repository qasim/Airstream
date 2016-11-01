# Airstream

> An iOS / macOS framework for streaming audio between Apple devices using AirPlay.

![An example gif](https://s15.postimg.org/sdw8gr0bf/screen_recording.gif)

You can use Airstream to start an AirPlay server in your iOS or macOS applications. Then, any Apple device can stream audio to your application via AirPlay, with no extra software required.

## Table of contents

* [Basic usage](#basic-usage)
* [API reference](#api-reference)
  * [Airstream](#airstream-1)
  * [AirstreamDelegate](#airstreamdelegate)
  * [AirstreamRemote](#airstreamremote)
* [Shairplay](#shairplay)
* [License](#license)

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

For a more detailed example on how to use Airstream, you can refer to the example projects which implement Airstream with the streamed audio output going directly to speakers via CoreAudio:

* [iOS Example](https://github.com/qasim/Airstream/tree/master/Examples/Airstream%20iOS%20Example)
* [macOS Example](https://github.com/qasim/Airstream/tree/master/Examples/Airstream%20macOS%20Example)

## API reference

### Airstream

This is the main class, from which you can start and stop the AirPlay server.

-

```swift
func init()
func init(name: String?)
func init(name: String?, password: String?)
func init(name: String?, password: String?, port: UInt)
```

Basic initializers for the Airstream.

-

```swift
func startServer()
```

Starts the AirPlay server and begins broadcasting.

-

```swift
func stopServer()
```

Gracefully shuts down the AirPlay server.

-

```swift
var name: String
```

The AirPlay server's receiver name. This is what is shown to devices when they go to connect to your AirPlay server. `"My Airstream"` by default.

-

```swift
var password: String?
```

The AirPlay server's receiver password. You can set this to prompt any Apple devices that wish to connect to your AirPlay server with a password challenge.

-

```swift
var port: UInt
```

The port where the AirPlay server should broadcast to. `5000` by default.

-

```swift
var running: Bool
```

Determines whether the server is currently running or not.

-

```swift
var remote: AirstreamRemote?
```

The reference to this Airstream's remote control object, which can be used to send commands to the connected device. This variable may not be set until the delegate has called `airstream:didGainAccessToRemote:`.

-

```swift
var volume: Float?
```

The connected Apple device's volume, between `0.0` (no volume) and `1.0` (maximum volume).

-

```swift
var metadata: [String: String]?
```

The metadata for the current item being streamed.

-

```swift
var coverart: Data?
```

The JPEG artwork (in binary) for the current item being streamed.

-

```swift
var position: UInt
```

The position (in seconds) of the current item being streamed.

-

```swift
var duration: UInt
```

The total duration (in seconds) of the current item being streamed.

-

### AirstreamDelegate

This is the delegate class for [Airstream](#airstream-1). By conforming to this protocol, you can listen for changes in AirPlay server status and be notified when data changes.

-

```swift
optional func airstream(_ airstream: Airstream, willStartStreamingWithStreamFormat streamFormat: AudioStreamBasicDescription)
```

Called right after a device has connected and is about to stream audio. [AudioStreamBasicDescription](https://developer.apple.com/reference/coreaudio/audiostreambasicdescription) is a struct outlining the details of the audio output.

-

```swift
optional func airstreamDidStopStreaming(_ airstream: Airstream)
```

Called right after a device has disconnected.

-

```swift
optional func airstream(_ airstream: Airstream, didGainAccessToRemote remote: AirstreamRemote)
```

Called right after the remote control connection has been setup.

-

```swift
optional func airstream(_ airstream: Airstream, processAudio buffer: UnsafeMutablePointer<Int8>, length: Int32)
```

Process linear PCM audio streamed from a device. `buffer` is a pointer to the audio data, and `length` is the number of bytes stored there.

-

```swift
optional func airstreamFlushAudio(_ airstream: Airstream)
```

Reset any audio output buffers you may be using, as the source has either changed or been disrupted.

-

```swift
optional func airstream(_ airstream: Airstream, didSetVolume volume: Float)
```

Called when a device's volume was changed.

-

```swift
optional func airstream(_ airstream: Airstream, didSetMetadata metadata: [String: String])
```

Called when a device's metadata for the current item being streamed was changed.

-

```swift
optional func airstream(_ airstream: Airstream, didSetCoverart coverart: Data)
```

Called when a device's artwork for the current item being streamed was changed.

-

```swift
optional func airstream(_ airstream: Airstream, didSetPosition position: UInt, duration: UInt)
```

Called when a device's current position or duration for the current item being streamed was changed.

-

### AirstreamRemote

This is the remote control object. If this is present on the [Airstream](#airstream-1) object, then you will be able to send commands to the device connected to your AirPlay server.

-

```swift
func play()
```

Start playback.

-

```swift
func pause()
```

Pause playback.

-

```swift
func stop()
```

Stop playback.

-

```swift
func playPause()
```

Toggle between starting and pausing playback.

-

```swift
func playResume()
```

Play after fast forwarding or rewinding.

-

```swift
func forward()
```

Begin fast forward.

-

```swift
func rewind()
```

Begin rewind.

-

```swift
func nextItem()
```

Play next item in playlist.

-

```swift
func previousItem()
```

Play previous item in playlist.

-

```swift
func shuffle()
```

Shuffle items in playlist.

-

```swift
func increaseVolume()
```

Turn audio volume up.

-

```swift
func decreaseVolume()
```

Turn audio volume down.

-

```swift
func toggleMute()
```

Toggle mute status.

## Shairplay

Airstream works by depending on a C library called [shairplay](https://github.com/juhovh/shairplay), which is a free portable AirPlay server implementation. You can also visit [qasim/shairplay](https://github.com/qasim/shairplay) for the fork of shairplay that is used by Airstream, which compiles on both iOS and macOS.

## License

Airstream is released under the MIT license. See [LICENSE](./LICENSE) for details.
