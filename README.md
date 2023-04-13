# AudioProcessor 🎙️

_A Swift Package for seamless audio recording on iOS devices._

AudioProcessor is an intuitive Swift Package tailored for effortless audio recording and management on iOS devices. By providing a designated folder, you can store and organize your recorded audio files with ease. The package offers advanced splitting capabilities, allowing you to:

1. Split files at specified intervals 🕒
2. Detect pauses in speech and automatically split files based on them 🤫

## Features ✨

* **Intuitive Folder Management**: Effortlessly store and manage your audio files in a designated folder.
* **Customizable Splitting Intervals**: Define specific intervals for splitting audio files to suit your requirements.
* **Automatic Pause Detection**: Detect pauses in speech and split files accordingly for optimal organization.

# Usage

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

Then you simply uses AsyncStreaming to get recorded files urls: 

```swift
for try await fileURL in audioProcessor.recordingStream {
    print("New recording: \(fileURL)")
}
```

