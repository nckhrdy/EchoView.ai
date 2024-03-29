import SwiftUI

struct ContentView: View {
    @ObservedObject var speechRecognizer: SpeechRecognizer
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var showingDetailScreen = false
    var bluetoothManager: BluetoothManager // Declare the BluetoothManager

    // Initialize ContentView with a BluetoothManager
    init(bluetoothManager: BluetoothManager) {
        self.bluetoothManager = bluetoothManager
        self.speechRecognizer = SpeechRecognizer(bluetoothManager: bluetoothManager) // Pass BluetoothManager to SpeechRecognizer
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background layer
                LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.6)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                // Content layer
                VStack {
                    // App Name Header
                    Text("EchoView.ai")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 50)
                    
                    Spacer()
                    
                    // Start New Transcription Button
                    Button(action: {
                        showingDetailScreen = true
                    }) {
                        HStack {
                            Image(systemName: "mic.fill")
                                .font(.title)
                            Text("Start a New Transcription")
                                .fontWeight(.medium)
                         }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(40)
                        .padding(.horizontal)
                    }
                    
                    // Manual Send Test Button
                    Button("Test Send Message") {
                        bluetoothManager.manualSendMessageTest()
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.bottom, 20)
                    
                    // Transcription History Link
                    NavigationLink(destination: TranscriptionHistoryView().environment(\.managedObjectContext, managedObjectContext)) {
                        Text("Transcription History")
                            .fontWeight(.medium)
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(Color.white.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(40)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                
                // Sheet presentation
                .sheet(isPresented: $showingDetailScreen) {
                    TranscriptionDetailView(speechRecognizer: speechRecognizer, onDismiss: { showingDetailScreen = false })
                        .environment(\.managedObjectContext, managedObjectContext)
                }
            }
        }
        .navigationBarHidden(true)
    }
}
