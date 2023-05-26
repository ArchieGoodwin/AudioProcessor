# AudioProcessor 🎙️

_A Swift Package for seamless audio recording on iOS and macOS devices._

AudioProcessor is an intuitive Swift Package tailored for effortless audio recording and management on iOS and macOS devices. By providing a designated folder, you can store and organize your recorded audio files with ease. The package offers advanced splitting capabilities, allowing you to:

1. Split files at specified intervals 🕒
2. Detect pauses in speech and automatically split files based on them 🤫

## Features ✨

* **Intuitive Folder Management**: Effortlessly store and manage your audio files in a designated folder.
* **Customizable Splitting Intervals**: Define specific intervals for splitting audio files to suit your requirements.
* **Automatic Pause Detection**: Detect pauses in speech and split files accordingly for optimal organization.
* **Support for Audio streaming** Returns streaming Data to provided callback

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

If you want to receive constant streaming of Data then: 
```swift
var audioProcessor = AudioProcessor()
audioProcessor.startStreaming { data in
    //your data processing
}
```

## License

MIT License

Copyright (c) [2023] [wilder.dev LLC]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

