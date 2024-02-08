//
//  HostChatView+ViewModel.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 19/11/2023.
//

import SwiftUI
import Combine

extension HostChatView {
    @MainActor final class ViewModel: ObservableObject {
        private let chatHost: ChatHost

        // For more fine tuned control over when SwiftUI will re-draw the view.
        @Published private(set) var viewUpdateTrigger: Bool = false

        // Trigger for Incoming Reaction Animation.
        @Published private(set) var incomingReactionTrigger: Bool = false

        private(set) var incomingReaction: String = ""

        private(set) var chatSections: [ChatSection] = []

        private var pendingMessage: String = ""
        private var sentReaction: String? = nil

        private var subscriptions = Set<AnyCancellable>()

        init(chatHost: ChatHost) {
            self.chatHost = chatHost
        }
    }
}

extension HostChatView.ViewModel {
    func didAppear() {
        chatHost.state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else {
                    return assertionFailure("Self is gone")
                }

                switch state {
                    case .off:
                        break

                    case .ready:
                        self.chatHost.startBroadcast()

                    case .unauthorised:
                        self.chatSections.append(HostChatView.ChatSection(
                            title: "Bluetooth Unavailable", chatMessages: []
                        ))

                    case .broadcasting:
                        self.chatSections.append(HostChatView.ChatSection(
                            title: "Waiting for Guests", chatMessages: []
                        ))
                }

                self.viewUpdateTrigger.toggle()
            }
            .store(in: &subscriptions)

        chatHost.chatEvents
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self else {
                    return assertionFailure("Self is gone")
                }

                switch event {
                    case .guestJoined:
                        self.chatSections.append(HostChatView.ChatSection(
                            title: "Guest Joined", chatMessages: []
                        ))

                    case .guestLeft:
                        self.chatSections.append(HostChatView.ChatSection(
                            title: "Guest Left", chatMessages: []
                        ))
                }

                self.viewUpdateTrigger.toggle()
            }
            .store(in: &subscriptions)

        chatHost.messages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let self else {
                    return assertionFailure("Self is gone")
                }

                if self.chatSections.isEmpty {
                    return
                }

                self.chatSections[self.chatSections.count - 1].chatMessages.append(
                    HostChatView.ChatSection.ChatMessage(
                        message: message, incoming: true
                    )
                )

                self.viewUpdateTrigger.toggle()
            }
            .store(in: &subscriptions)

        chatHost.reactions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] reaction in
                guard let self else {
                    return assertionFailure("Self is gone")
                }

                self.incomingReaction = reaction

                self.incomingReactionTrigger.toggle()
            }
            .store(in: &subscriptions)
    }

    func didDisappear() {
        subscriptions.removeAll()

        chatHost.stopBroadcast()
    }

    func sendMessage() {
        if pendingMessage.isEmpty {
            return
        }

        chatHost.submit(message: pendingMessage)

        if chatSections.isEmpty {
            return
        }

        chatSections[chatSections.count - 1].chatMessages.append(
            HostChatView.ChatSection.ChatMessage(
                message: pendingMessage, incoming: false
            )
        )

        pendingMessage = "" // Clear message field.

        viewUpdateTrigger.toggle()
    }

    var message: Binding<String> {
        Binding {
            self.pendingMessage
        } set: { message in
            self.pendingMessage = message
        }
    }

    var reaction: Binding<String?> {
        Binding {
            self.sentReaction
        } set: { reaction in
            defer {
                self.sentReaction = reaction
            }

            guard let reaction else {
                return
            }

            self.chatHost.submit(reaction: reaction)
        }
    }
}
