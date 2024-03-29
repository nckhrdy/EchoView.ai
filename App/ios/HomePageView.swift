import SwiftUI

struct HomePageView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var navigateToContentView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background layer with gradient
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
                    
                    // Scan for Devices Button
                    Button(action: {
                        if bluetoothManager.isScanning {
                            bluetoothManager.stopScanning()
                        } else {
                            bluetoothManager.startScanning()
                        }
                    }) {
                        HStack {
                            Image(systemName: bluetoothManager.isScanning ? "stop.fill" : "antenna.radiowaves.left.and.right")
                                .font(.title)
                            Text(bluetoothManager.isScanning ? "Stop Scanning" : "Scan for Devices")
                                .fontWeight(.medium)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(40)
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                    
                    // List of Discovered Peripherals
                    List(bluetoothManager.discoveredPeripherals, id: \.identifier) { peripheral in
                        Button(action: {
                            bluetoothManager.connect(to: peripheral)
                        }) {
                            Text(peripheral.name ?? "Unknown Device")
                                .fontWeight(.medium)
                                .padding()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .background(Color.white.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(40)
                        }
                        .padding(.horizontal)
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(PlainListStyle())

                    Spacer()
                }
                .onChange(of: bluetoothManager.isConnected) { isConnected in
                    navigateToContentView = isConnected
                }
                .background(NavigationLink(destination: ContentView(bluetoothManager: bluetoothManager).environment(\.managedObjectContext, managedObjectContext), isActive: $navigateToContentView) { EmptyView() })
            }
        }
        .navigationBarHidden(true)
    }
}
