//
//  PreviewChatHostScanner.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 23/11/2023.
//

import Foundation
import Combine

final class PreviewChatHostScanner: ChatHostScanner {
    final class PreviewChatHostConnection: ChatHostConnection {
        var state: AnyPublisher<ChatHostConnectionState, Never> {
            Empty().eraseToAnyPublisher()
        }

        var messages: AnyPublisher<String, Never> {
            Empty().eraseToAnyPublisher()
        }

        var reactions: AnyPublisher<String, Never> {
            Empty().eraseToAnyPublisher()
        }

        func submit(message: String) {

        }

        func submit(reaction: String) {

        }

        func disconnect() {

        }
    }

    var state: AnyPublisher<ChatHostScannerState, Never> {
        Empty().eraseToAnyPublisher()
    }

    var discoveries: AnyPublisher<ChatHostDiscovery, Never> {
        Empty().eraseToAnyPublisher()
    }

    func startScan() {

    }

    func stopScan() {

    }

    func connect(to uuid: UUID, _ completion: @escaping (Result<ChatHostConnection, Error>) -> Void) {
        completion(.success(PreviewChatHostConnection()))
    }
}
