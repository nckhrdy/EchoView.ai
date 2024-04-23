import SwiftUI
import CoreBluetooth

struct HomePageView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var navigateToContentView = false
    @State private var isScanning = false
    @State private var selectedPeripheral: CBPeripheral?
    @State private var pulse = false

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
                        .font(.custom("Jersey 10", size: 50)) // Use custom font "Jersey 10"
                        .foregroundColor(Color.purple) // Use the dark purple color defined
                        .padding(.top, 50)
                    
                    Spacer(minLength: 20)

                    Button(action: {
                        isScanning.toggle()
                        if isScanning {
                            bluetoothManager.startScanning()
                        } else {
                            bluetoothManager.stopScanning()
                        }
                    }) {
                        Label(isScanning ? "Stop Scanning" : "Scan for Glasses", systemImage: isScanning ? "stop.fill" : "antenna.radiowaves.left.and.right")
                            .font(.custom("Jersey 10", size: 30))
                            .padding()
                            .foregroundColor(.white)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(Color.purple) // Using a dark purple color
                            .cornerRadius(40)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, isScanning ? 10 : 20)
                    
                    if isScanning, let firstPeripheral = bluetoothManager.discoveredPeripherals.first {
                        Button(action: {
                            selectedPeripheral = firstPeripheral
                            bluetoothManager.connect(to: firstPeripheral)
                            navigateToContentView = true
                        }) {
                            Image(systemName: "eyeglasses")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(30)
                                .frame(width: 150, height: 150)
                                .background(Color.white) // Button background as white
                                .foregroundColor(.purple)
                                .clipShape(Circle())
                                .shadow(radius: 10) // Add shadow for depth
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $navigateToContentView) {
                ContentView(bluetoothManager: bluetoothManager).environment(\.managedObjectContext, managedObjectContext)
                    .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.9)))
            }
        }
    }
}
