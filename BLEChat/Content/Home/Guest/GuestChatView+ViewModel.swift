//
//  GuestChatView+ViewModel.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 19/11/2023.
//

import SwiftUI
import Combine

extension GuestChatView {
    @MainActor final class ViewModel: ObservableObject {
        private let chatHostScanner: ChatHostScanner

        let chatHostName: String
        let chatHostId: UUID

        // For more fine tuned control over when SwiftUI will re-draw the view.
        @Published private(set) var viewUpdateTrigger: Bool = false

        // Trigger for Incoming Reaction Animation.
        @Published private(set) var incomingReactionTrigger: Bool = false

        private(set) var incomingReaction: String = ""

        private(set) var chatSections: [ChatSection] = []

        private var pendingMessage: String = ""
        private var sentReaction: String? = nil

        private var chatHostConnection: ChatHostConnection?

        private var subscriptions = Set<AnyCancellable>()

        init(chatHostScanner: ChatHostScanner, chatHostName: String, chatHostId: UUID) {
            self.chatHostScanner = chatHostScanner
            self.chatHostName = chatHostName
            self.chatHostId = chatHostId
        }
    }
}

extension GuestChatView.ViewModel {
    func didAppear() {
        chatSections.append(GuestChatView.ChatSection(
            title: "Connecting to \(chatHostName)...", chatMessages: []
        ))

        viewUpdateTrigger.toggle()

        chatHostScanner.connect(to: chatHostId) { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                guard let self else {
                    return assertionFailure("Self is gone")
                }

                switch result {
                    case let .success(chatHostConnection):
                        chatHostConnection.state
                            .receive(on: DispatchQueue.main)
                            .sink { [weak self] state in
                                guard let self else {
                                    return assertionFailure("Self is gone")
                                }

                                switch state {
                                    case .connecting:
                                        break

                                    case .connected:
                                        self.chatSections.append(GuestChatView.ChatSection(
                                            title: "Connected to \(chatHostName)!",
                                            chatMessages: []
                                        ))

                                    case .disconnected:
                                        self.chatSections.append(GuestChatView.ChatSection(
                                            title: "Disconnected from \(chatHostName)...",
                                            chatMessages: []
                                        ))

                                    case .error:
                                        self.chatSections.append(GuestChatView.ChatSection(
                                            title: "Connection Error with \(chatHostName)...",
                                            chatMessages: []
                                        ))
                                }

                                self.viewUpdateTrigger.toggle()
                            }
                            .store(in: &self.subscriptions)

                        chatHostConnection.messages
                            .receive(on: DispatchQueue.main)
                            .sink { [weak self] message in
                                guard let self else {
                                    return assertionFailure("Self is gone")
                                }

                                if self.chatSections.isEmpty {
                                    return
                                }

                                self.chatSections[self.chatSections.count - 1].chatMessages.append(
                                    GuestChatView.ChatSection.ChatMessage(
                                        message: message, incoming: true
                                    )
                                )

                                self.viewUpdateTrigger.toggle()
                            }
                            .store(in: &self.subscriptions)

                        chatHostConnection.reactions
                            .receive(on: DispatchQueue.main)
                            .sink { [weak self] reaction in
                                guard let self else {
                                    return assertionFailure("Self is gone")
                                }

                                self.incomingReaction = reaction

                                self.incomingReactionTrigger.toggle()
                            }
                            .store(in: &subscriptions)

                        self.chatHostConnection = chatHostConnection

                    case .failure:
                        self.chatSections.append(GuestChatView.ChatSection(
                            title: "Failed to connect to \(self.chatHostName)...",
                            chatMessages: []
                        ))

                        self.viewUpdateTrigger.toggle()
                }
            }
        }
    }

    func didDisappear() {
        subscriptions.removeAll()

        chatHostConnection?.disconnect()
    }

    func sendMessage() {
        if pendingMessage.isEmpty {
            return
        }

        chatHostConnection?.submit(message: pendingMessage)

        if chatSections.isEmpty {
            return
        }

        chatSections[chatSections.count - 1].chatMessages.append(
            GuestChatView.ChatSection.ChatMessage(
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

            self.chatHostConnection?.submit(reaction: reaction)
        }
    }
}
