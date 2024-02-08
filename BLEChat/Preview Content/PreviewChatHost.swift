//
//  PreviewChatHost.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 23/11/2023.
//

import Foundation
import Combine

final class PreviewChatHost: ChatHost {
    var state: AnyPublisher<ChatHostState, Never> {
        Empty().eraseToAnyPublisher()
    }

    var chatEvents: AnyPublisher<ChatEvent, Never> {
        Empty().eraseToAnyPublisher()
    }

    var messages: AnyPublisher<String, Never> {
        Empty().eraseToAnyPublisher()
    }

    var reactions: AnyPublisher<String, Never> {
        Empty().eraseToAnyPublisher()
    }

    func startBroadcast() {

    }

    func stopBroadcast() {

    }

    func submit(message: String) {

    }

    func submit(reaction: String) {

    }
}
