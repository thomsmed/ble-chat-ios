//
//  BLEChatApp.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 19/11/2023.
//

import SwiftUI

@main
struct BLEChatApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: .init(
                appDependencies: appDelegate.appDependencies
            ))
        }
    }
}
