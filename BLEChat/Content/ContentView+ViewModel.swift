//
//  ContentView+ViewModel.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 19/11/2023.
//

import SwiftUI

extension ContentView {
    @MainActor final class ViewModel: ObservableObject {
        private let appDependencies: AppDependencies

        @Published var pageStack: [Page] = []

        init(appDependencies: some AppDependencies) {
            self.appDependencies = appDependencies
        }
    }
}

// MARK: ViewModel Factory

extension ContentView.ViewModel {
    func makeHomeViewModel() -> HomeView.ViewModel {
        HomeView.ViewModel(
            appDependencies: appDependencies
        ) { [weak self] event in
            switch event {
                case .didTapHost:
                    self?.pageStack.append(.hostChat)

                case .didTapJoin:
                    self?.pageStack.append(.joinChat)
            }
        }
    }

    func makeHostChatViewModel() -> HostChatView.ViewModel {
        HostChatView.ViewModel(chatHost: appDependencies.chatHost)
    }

    func makeJoinChatViewModel() -> JoinChatView.ViewModel {
        JoinChatView.ViewModel(
            chatHostScanner: appDependencies.chatHostScanner
        ) { [weak self] event in
            switch event {
                case let .didSelectHost(chatHostName, chatHostId):
                    self?.pageStack.append(.guestChat(
                        chatHostName: chatHostName, chatHostId: chatHostId
                    ))
            }
        }
    }

    func makeGuestChatViewModel(
        chatHostName: String,
        chatHostId: UUID
    ) -> GuestChatView.ViewModel {
        GuestChatView.ViewModel(
            chatHostScanner: appDependencies.chatHostScanner,
            chatHostName: chatHostName,
            chatHostId: chatHostId
        )
    }
}
