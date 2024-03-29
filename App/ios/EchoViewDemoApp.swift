//
//  EchoViewDemoApp.swift
//  EchoViewDemo
//
//  Created by Nick Hardy on 3/27/24.
//

import SwiftUI

@main
struct EchoViewDemoApp: App {
    let persistenceController = PersistenceController.shared
    // Initialize the BluetoothManager
    var bluetoothManager = BluetoothManager()
    
    var body: some Scene {
        WindowGroup {
            // Use HomePageView as the entry point
            HomePageView()
                // Provide the managedObjectContext environment value
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                // Provide the BluetoothManager as an environment object
                .environmentObject(bluetoothManager)
        }
    }
}
