// VoiceControlView.swift
// Feature 4: Voice‑controlled navigation placeholder implementation

import SwiftUI
import Speech

/// A simple SwiftUI view that starts speech recognition and forwards the spoken text
/// to a handler that can interpret commands such as "show mars" or "switch to night mode".
struct VoiceControlView: View {
    @State private var isRecording = false
    @State private var transcript = ""
    private let recognizer = SFSpeechRecognizer()
    private var request = SFSpeechAudioBufferRecognitionRequest()
    private var audioEngine = AVAudioEngine()

    var body: some View {
        VStack {
            Text(transcript)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            Button(isRecording ? "Stop Listening" : "Start Listening") {
                isRecording ? stopListening() : startListening()
            }
            .padding()
            .background(isRecording ? Color.red : Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }

    private func startListening() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            guard authStatus == .authorized else { return }
            DispatchQueue.main.async { self.isRecording = true }
            let node = audioEngine.inputNode
            let format = node.outputFormat(forBus: 0)
            node.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                self.request.append(buffer)
            }
            self.audioEngine.prepare()
            try? self.audioEngine.start()
            recognizer?.recognitionTask(with: request) { result, error in
                if let result = result {
                    DispatchQueue.main.async {
                        self.transcript = result.bestTranscription.formattedString
                        // TODO: Parse commands from transcript and trigger UI changes.
                    }
                }
                if error != nil {
                    stopListening()
                }
            }
        }
    }

    private func stopListening() {
        audioEngine.stop()
        request.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
        DispatchQueue.main.async { self.isRecording = false }
    }
}

struct VoiceControlView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceControlView()
    }
}
