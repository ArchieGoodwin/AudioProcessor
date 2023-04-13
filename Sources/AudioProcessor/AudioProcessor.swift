//
//  AudioProcessor.swift
//  whisper.swiftui
//
//  Created by Sergey Dikarev on 07.04.2023.
//

import Foundation
import AVFoundation

class AudioProcessor: NSObject, AVAudioRecorderDelegate, ObservableObject {
    
    private var audioRecorder: AVAudioRecorder?
    private var recordingSession: AVAudioSession?
    private var filePath: URL!
    private var timer: Timer?
    private var pauseTimer: Timer?
    public var recordingInterval: TimeInterval = 20
    public var pauseThreshold: Float = -40.0
    public var pauseDuration: TimeInterval = 1.5
    private var pauseDurationCounter: TimeInterval = 0
    private var directory: String = NSTemporaryDirectory()

    
    var recordingStream: AsyncThrowingStream<URL, Error> {
            AsyncThrowingStream { continuation in
                self.recordingContinuation = continuation
            }
    }
    
    private var recordingContinuation: AsyncThrowingStream<URL, Error>.Continuation?
    
    func start(directory: String) {
        self.directory = directory
        setupRecordingSession()
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
                        // Handle permission denied
                    }
                }
            }
        } catch {
            // Handle errors during setup
        }
    }
    
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
            audioRecorder = try AVAudioRecorder(url: filePath, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()

            timer = Timer.scheduledTimer(timeInterval: recordingInterval, target: self, selector: #selector(stopAndRestartRecording), userInfo: nil, repeats: false)

            // Add a timer to check for pauses
            if pauseDuration > 0 {
                pauseTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(checkForPause), userInfo: nil, repeats: true)

            }
            
        } catch {
            // Handle errors during recording setup
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        
        audioRecorder?.stop()
        recordingContinuation?.yield(filePath)

        try? recordingSession?.setActive(false, options: .notifyOthersOnDeactivation)
        recordingSession = nil

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
        audioRecorder?.stop()
        recordingContinuation?.yield(filePath)

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
