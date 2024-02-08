//
//  JoinChatView+ViewModel.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 19/11/2023.
//

import SwiftUI
import Combine

extension JoinChatView {
    @MainActor final class ViewModel: EventEmittingViewModel<Event>, ObservableObject {
        private let chatHostScanner: ChatHostScanner

        // For more fine tuned control over when SwiftUI will re-draw the view.
        @Published private(set) var viewUpdateTrigger: Bool = false

        private(set) var isScanning: Bool = false
        private(set) var chatHostSections: [ChatHostSection] = []

        private var subscriptions = Set<AnyCancellable>()

        init(
            chatHostScanner: ChatHostScanner,
            onEvent: @escaping (Event) -> Void
        ) {
            self.chatHostScanner = chatHostScanner
            super.init(onEvent: onEvent)
        }
    }
}

extension JoinChatView.ViewModel {
    func didAppear() {
        chatHostScanner.state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else {
                    return assertionFailure("Self is gone")
                }

                switch state {
                    case .off:
                        break

                    case .ready:
                        self.chatHostScanner.startScan()

                    case .unauthorised:
                        self.chatHostSections.append(JoinChatView.ChatHostSection(
                            title: "Bluetooth Unavailable", chatHosts: []
                        ))

                    case .scanning:
                        self.isScanning = true

                        self.chatHostSections.append(JoinChatView.ChatHostSection(
                            title: "Searching for Hosts...", chatHosts: []
                        ))
                }

                self.viewUpdateTrigger.toggle()
            }
            .store(in: &subscriptions)

        chatHostScanner.discoveries
            .receive(on: DispatchQueue.main)
            .sink { [weak self] discovery in
                guard let self else {
                    return assertionFailure("Self is gone")
                }

                if self.chatHostSections.isEmpty {
                    return
                }

                switch discovery {
                    case let .discovered(discoveredChatHost):
                        self.chatHostSections[self.chatHostSections.count - 1].chatHosts.insert(
                            JoinChatView.ChatHostSection.ChatHost(
                                id: discoveredChatHost.uuid,
                                name: discoveredChatHost.name ?? String(localized: "Unknown"),
                                lastSeen: discoveredChatHost.lastSeen
                            ), at: 0
                        )

                    case let .rediscovered(discoveredChatHost):
                        if let alreadyDiscoveredChatHostIndex = self.chatHostSections[self.chatHostSections.count - 1].chatHosts.firstIndex(
                            where: { $0.id == discoveredChatHost.uuid }
                        ) {
                            self.chatHostSections[self.chatHostSections.count - 1].chatHosts.remove(
                                at: alreadyDiscoveredChatHostIndex
                            )
                        }

                        // Insert rediscovered chat host at the top of the chat host list.
                        self.chatHostSections[self.chatHostSections.count - 1].chatHosts.insert(
                            JoinChatView.ChatHostSection.ChatHost(
                                id: discoveredChatHost.uuid,
                                name: discoveredChatHost.name ?? String(localized: "Unknown"),
                                lastSeen: discoveredChatHost.lastSeen
                            ), at: 0
                        )
                }

                self.viewUpdateTrigger.toggle()
            }
            .store(in: &subscriptions)
    }

    func didDisappear() {
        subscriptions.removeAll()

        chatHostSections.removeAll()

        viewUpdateTrigger.toggle() // Prepare for when the View appears again.

        chatHostScanner.stopScan()
    }

    func didSelect(_ chatHostName: String, withId chatHostId: UUID) {
        onEvent(.didSelectHost(chatHostName: chatHostName, chatHostId: chatHostId))
    }
}
