import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @ObservedObject var speechRecognizer: SpeechRecognizer
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var showingDetailScreen = false
    var bluetoothManager: BluetoothManager

    init(bluetoothManager: BluetoothManager) {
        self.bluetoothManager = bluetoothManager
        self.speechRecognizer = SpeechRecognizer(bluetoothManager: bluetoothManager)
    }

    var body: some View {
        NavigationView {
            ZStack {
                Image("Gray Building Low Angle") // Set your photo name here
                    .resizable()
                    .aspectRatio(contentMode: .fill) // Fill the entire background
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill the entire screen
                    .edgesIgnoringSafeArea(.all) // Extend to the edges of the display
                VStack {
                    Text("EchoView.ai")
                        .font(.custom("Jersey 10", size: 50))
                        .foregroundColor(.purple)
                        .padding(.top, 50)
                    
                    Spacer()

                    // Central circular button made larger
                    Button(action: {
                        showingDetailScreen = true
                        speechRecognizer.startTranscribing()
                    }) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 60)) // Increased font size
                            .padding(40) // Increased padding to make the button larger
                            .background(Color.white.opacity(0.9))
                            .clipShape(Circle())
                            .shadow(radius: 10)
                            .overlay(
                                Circle()
                                    .stroke(LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.purple.opacity(0.6)]), startPoint: .leading,endPoint: .trailing), lineWidth: 6)
                            )
                            .foregroundColor(.purple)
                    }

                    Spacer()

                    NavigationLink(destination: TranscriptionHistoryView().environment(\.managedObjectContext, managedObjectContext)) {
                        Text("Conversation History")
                            .font(.custom("Jersey 10", size: 30))
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(Color.white.opacity(0.7))
                            .foregroundColor(.purple)
                            .cornerRadius(20)
                            .padding(.horizontal)
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .sheet(isPresented: $showingDetailScreen) {
                TranscriptionDetailView(speechRecognizer: speechRecognizer, onDismiss: { showingDetailScreen = false })
                    .environment(\.managedObjectContext, managedObjectContext)
            }
        }
        .navigationBarHidden(true)
    }
}
