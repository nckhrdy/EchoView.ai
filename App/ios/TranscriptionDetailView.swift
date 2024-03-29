import SwiftUI
import CoreData

struct TranscriptionDetailView: View {
    @ObservedObject var speechRecognizer: SpeechRecognizer
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var date = Date()
    @State private var conversation = ""

    var onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.6)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // Date picker
                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .padding()
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(10)
                
                // Conversation topic text field
                TextField("Conversation Topic", text: $conversation)
                    .padding()
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                // Start transcribing button
                Button("Start Transcribing") {
                    speechRecognizer.startTranscribing()
                }
                .padding()
                .background(Color.green.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
                
                // Stop transcribing and save button
                Button("Stop Transcribing") {
                    let newTranscription = Transcription(context: managedObjectContext)
                    newTranscription.date = date
                    newTranscription.conversation = conversation
                    newTranscription.transcript = speechRecognizer.transcript

                    do {
                        try managedObjectContext.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                    speechRecognizer.stopTranscribing()
                    onDismiss()
                }
                .padding()
                .background(Color.red.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
                
                // Transcript display
                ScrollView {
                    Text(speechRecognizer.transcript.isEmpty ? "Transcription will appear here..." : speechRecognizer.transcript)
                        .padding()
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(10)
                }
                .frame(height: 300)
                .padding(.horizontal)
            }
            .padding()
        }
    }
}
