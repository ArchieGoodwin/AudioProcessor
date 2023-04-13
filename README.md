# AudioProcessor

AudioProcessor - Swift Package designed for seamless audio recording on iOS devices. With its intuitive folder management, this package stores your recorded audio files in a designated folder. The real power of AudioProcessor lies in its splitting capabilities. Customise your recordings by splitting files at specified intervals of time or detect pauses in audio for automatic segmentation.

## Parameters

* `recordingInterval: TimeInterval = 20`: This parameter determines the splitting interval for recordings (in seconds). The default value is 20 seconds.

* `pauseThreshold: Float = -40.0`: This parameter sets the threshold for detecting pauses in the audio (in decibels). The default value is -40 dB.

* `pauseDuration: TimeInterval = 1.5`: This parameter defines the duration of the pause to detect in the audio (in seconds). The default value is 1.5 seconds.

## Example Usage

To use the AudioProcessor package, initialize it as shown below:

```swift
var audioProcessor = AudioProcessor()
audioProcessor.start(directory: NSTemporaryDirectory())
```

Then you simply uses AsyncStreaming to get recored files urls: 

```swift
for try await fileURL in audioProcessor.recordingStream {
    print("New recording: \(fileURL)")
}
```

