//
//  AudioProcessor.swift
//  whisper.swiftui
//
//  Created by Sergey Dikarev on 07.04.2023.
//

import Foundation
import AVFoundation

public class AudioProcessor: NSObject, AVAudioRecorderDelegate, ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var filePath: URL?
    private var timer: Timer?
    private var pauseTimer: Timer?
    private var pauseDurationCounter: TimeInterval = 0
    private var directory: String = NSTemporaryDirectory()
    private var recordingContinuation: AsyncThrowingStream<URL, Error>.Continuation?
    public var recordingInterval: TimeInterval = 20
    public var pauseThreshold: Float = -40.0
    public var pauseDuration: TimeInterval = 1.5
    private var pauseDurationCounter: TimeInterval = 0
    private var directory: String = NSTemporaryDirectory()
    
    private var callbackStreaming: ((Data) -> Void)? = nil
    private let audioEngine = AVAudioEngine()

    public var recordingStream: AsyncThrowingStream<URL, Error> {
        AsyncThrowingStream { continuation in
            self.recordingContinuation = continuation
        }
    }
    
    public func start(directory: String) {
        self.directory = directory
        
        #if os(iOS) || os(tvOS)
        setupRecordingSession()
        #else
        startRecording()
        #endif
    }
    
    #if os(iOS) || os(tvOS)
    private var recordingSession: AVAudioSession?
    public func startStreaming(callback: @escaping (Data) -> Void) {
        self.callbackStreaming = callback
    }
   
    private func startAnalyzingAudio() {
        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.inputFormat(forBus: 0)
        let outputFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: inputFormat.sampleRate, channels: inputFormat.channelCount, interleaved: true)
        let converterNode = AVAudioMixerNode()
        let sinkNode = AVAudioMixerNode()
        
        audioEngine.attach(converterNode)
        audioEngine.attach(sinkNode)
        
        converterNode.installTap(onBus: 0, bufferSize: 1024, format: converterNode.outputFormat(forBus: 0)) { (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
            if let data = self.toNSData(buffer: buffer) {
                if let callback = self.callbackStreaming {
                    callback(data)
                }
            }
        }
        
        audioEngine.connect(inputNode, to: converterNode, format: inputFormat)
        audioEngine.connect(converterNode, to: sinkNode, format: outputFormat)
        audioEngine.prepare()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.record)
            try audioEngine.start()
        } catch {
            print(error)
        }
    }
    
    private func toNSData(buffer: AVAudioPCMBuffer) -> Data? {
        let audioBuffer = buffer.audioBufferList.pointee.mBuffers
        return Data(bytes: audioBuffer.mData!, count: Int(audioBuffer.mDataByteSize))
    }
    
    func setupRecordingSession() {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession?.setCategory(.playAndRecord, mode: .default)
            try recordingSession?.setActive(true)
            recordingSession?.requestRecordPermission { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.startRecording()
                    } else {
                        // TODO: Handle permission denied
                    }
                }
            }
        } catch {
            // TODO: Handle errors during setup
        }
    }
    #endif
    
    func startRecording() {
        let fileName = "recording-\(Date().timeIntervalSince1970).wav"
        filePath = URL(fileURLWithPath: directory).appendingPathComponent(fileName)
        
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            guard let path = filePath else {
                return
            }
            audioRecorder = try AVAudioRecorder(url: path, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            timer = Timer.scheduledTimer(timeInterval: recordingInterval, target: self, selector: #selector(stopAndRestartRecording), userInfo: nil, repeats: false)
            
            // Add a timer to check for pauses
            if pauseDuration > 0 {
                pauseTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(checkForPause), userInfo: nil, repeats: true)
            }
            
        } catch {
            // TODO: Handle errors during recording setup
        }
    }
    
    public func stop() {
        timer?.invalidate()
        timer = nil
        if let path = filePath {
            recordingContinuation?.yield(path)
        }
        
        audioRecorder?.stop()
        
        #if os(iOS) || os(tvOS)
        try? recordingSession?.setActive(false, options: .notifyOthersOnDeactivation)
        recordingSession = nil
        #endif
        
        if pauseDuration > 0 {
            // Stop and reset the pause timer
            pauseTimer?.invalidate()
            pauseTimer = nil
            pauseDurationCounter = 0
        }
        
        
    }
    
    @objc func stopAndRestartRecording() {
        if pauseTimer == nil && timer == nil {
            return
        }
        if let path = filePath {
            recordingContinuation?.yield(path)
        }
        audioRecorder?.stop()
        
        timer?.invalidate()
        timer = nil
        
        
        if pauseDuration > 0 {
            // Stop and reset the pause timer
            pauseTimer?.invalidate()
            pauseTimer = nil
            pauseDurationCounter = 0
        }
        
        
        startRecording()
    }
    
    
    @objc func checkForPause() {
        if pauseTimer == nil {
            return
        }
        audioRecorder?.updateMeters()
        if let audioLevel = audioRecorder?.averagePower(forChannel: 0)
        {
            if audioLevel < pauseThreshold {
                pauseDurationCounter += 0.1
                if pauseDurationCounter >= pauseDuration {
                    stopAndRestartRecording()
                }
            } else {
                pauseDurationCounter = 0
            }
        }
        
    }
}
