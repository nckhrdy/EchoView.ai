import Foundation
import AVFoundation
import Speech
import SwiftUI
import UIKit // Necessary for handling app lifecycle notifications and background tasks.

class SpeechRecognizer: NSObject, ObservableObject {
    // Enumeration to handle different types of errors that might occur.
    enum RecognizerError: Error {
        case nilRecognizer
        case notAuthorizedToRecognize
        case notPermittedToRecord
        case recognizerIsUnavailable

        // Provide user-friendly messages for each error type.
        var message: String {
            switch self {
            case .nilRecognizer: return "Can't initialize speech recognizer."
            case .notAuthorizedToRecognize: return "Not authorized to recognize speech."
            case .notPermittedToRecord: return "Not permitted to record audio."
            case .recognizerIsUnavailable: return "Recognizer is unavailable."
            }
        }
    }

    @Published var transcript: String = "" // Published property to update transcript in the UI.

    private var audioEngine: AVAudioEngine? // Used for audio input.
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest? // Request for speech recognition.
    private var recognitionTask: SFSpeechRecognitionTask? // Task handling speech recognition.
    private let speechRecognizer = SFSpeechRecognizer() // Speech recognizer object.
    private var lastSentTranscript: String = "" // Stores the last piece of transcript sent to the ESP device.
    
    // Reference to a custom BluetoothManager class for managing BLE communications.
    var bluetoothManager: BluetoothManager?

    // Convenience initializer to inject a BluetoothManager instance.
    convenience init(bluetoothManager: BluetoothManager) {
        self.init()
        self.bluetoothManager = bluetoothManager
    }

    override init() {
        super.init()
        requestPermissions() // Request necessary permissions upon initialization.
        setupNotifications() // Setup notifications for app background/foreground transitions.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self) // Clean up observers on deinitialization.
    }

    // Starts the transcription process.
    func startTranscribing() {
        resetTranscription()
        startAudioEngine()
    }

    // Stops the transcription process.
    func stopTranscribing() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0) // Remove audio input tap.
        recognitionRequest?.endAudio() // Signal the end of audio input.
        recognitionTask?.cancel() // Cancel the ongoing recognition task.
        endBackgroundTask() // Ensure the background task is properly ended.
    }

    // Resets the current transcription.
    private func resetTranscription() {
        transcript = ""
        lastSentTranscript = ""
        recognitionTask?.cancel()
        recognitionTask = nil
    }

    // Configures and starts the audio engine for capturing audio input.
    private func startAudioEngine() {
        guard speechRecognizer?.isAvailable ?? false else {
            transcribeError(RecognizerError.recognizerIsUnavailable)
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object.")
        }
        recognitionRequest.shouldReportPartialResults = true // Enable partial results to be reported.

        do {
            let audioEngine = AVAudioEngine()
            self.audioEngine = audioEngine

            let inputNode = audioEngine.inputNode // Get the audio input node.
            let recordingFormat = inputNode.outputFormat(forBus: 0) // Get the input node's recording format.
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                recognitionRequest.append(buffer) // Append audio input to the recognition request.
            }

            audioEngine.prepare() // Prepare the audio engine.
            try audioEngine.start() // Start the audio engine.

            startBackgroundTask() // Start a background task to ensure continuous operation in the background.

            // Start the recognition task.
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                guard let self = self else { return }
                var isFinal = false

                if let result = result {
                    // Process the result and update the transcript.
                    self.processResult(result)
                    isFinal = result.isFinal
                }

                if error != nil || isFinal {
                    // If an error occurs or the result is final, stop transcribing.
                    self.stopTranscribing()
                }
            }
        } catch {
            // Handle errors in starting the audio engine.
            transcribeError(error)
        }
    }

    // Processes speech recognition results and handles updating the transcript and sending data over BLE.
    private func processResult(_ result: SFSpeechRecognitionResult) {
        let transcription = result.bestTranscription.formattedString
            
            // Only proceed if new text has been added.
            guard transcription != lastSentTranscript else { return }
            
            // Determine the new chunk of text.
            let newText = transcription.replacingOccurrences(of: lastSentTranscript, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            if !newText.isEmpty {
                // Split the new text into words
                let words = newText.split(separator: " ")
                
                // Iterate over each word and send it individually
                for word in words {
                    bluetoothManager?.sendMessage(String(word))
                    Thread.sleep(forTimeInterval: 0.1) // Adds a 200ms delay between sending each word
                    // Consider adding a slight delay here if needed to prevent overwhelming the BLE queue.
                }
                
                // Update the last sent transcript with the full new transcription to avoid re-sending words.
                lastSentTranscript = transcription
            }
            
            // Update the transcript for the UI.
            DispatchQueue.main.async {
                self.transcript = transcription
            }
    }

    // Handles errors that occur during the transcription process.
    private func transcribeError(_ error: Error) {
        DispatchQueue.main.async {
            if let recognizerError = error as? RecognizerError {
                self.transcript = "<< \(recognizerError.message) >>"
            } else {
                self.transcript = "<< \(error.localizedDescription) >>"
            }
        }
    }

    // Requests permissions necessary for audio recording and speech recognition.
    private func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            // Handle authorization status for speech recognition as needed.
        }

        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .spokenAudio, options: [.allowBluetoothA2DP, .defaultToSpeaker])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }

    // MARK: Background Task Handling
    
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    private func startBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }

    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }

    // MARK: Notification Setup

    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc func appMovedToBackground() {
        startBackgroundTask()
    }

    @objc func appMovedToForeground() {
        endBackgroundTask()
        // Optionally restart transcription or audio tasks if they were stopped.
    }
}
