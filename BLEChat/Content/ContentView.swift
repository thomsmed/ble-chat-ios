//
//  ContentView.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 19/11/2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        NavigationStack(path: $viewModel.pageStack) {
            HomeView(
                viewModel: viewModel.makeHomeViewModel()
            )
            .navigationDestination(for: Page.self) { page in
                switch page {
                    case .joinChat:
                        JoinChatView(viewModel: viewModel.makeJoinChatViewModel())

                    case let .guestChat(chatHostName, chatHostId):
                        GuestChatView(viewModel: viewModel.makeGuestChatViewModel(
                            chatHostName: chatHostName, chatHostId: chatHostId
                        ))

                    case .hostChat:
                        HostChatView(viewModel: viewModel.makeHostChatViewModel())
                }
            }
        }
    }
}

#Preview {
    MainActor.assumeIsolated {
        ContentView(viewModel: .init(
            appDependencies: PreviewAppDependencies.shared
        ))
    }
}
