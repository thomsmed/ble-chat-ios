//
//  ChatHostScanner.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 19/11/2023.
//

import Foundation
import Combine

enum ChatHostError: Error {
    case invalidState
    case unknownPeripheral
    case connectionFailure
}

struct DiscoveredChatHost {
    let name: String?
    let uuid: UUID
    let lastSeen: Date
}

enum ChatHostDiscovery {
    case discovered(DiscoveredChatHost)
    case rediscovered(DiscoveredChatHost)
}

enum ChatHostScannerState {
    case off
    case ready
    case unauthorised
    case scanning
}

protocol ChatHostScanner: AnyObject {
    var state: AnyPublisher<ChatHostScannerState, Never> { get }
    var discoveries: AnyPublisher<ChatHostDiscovery, Never> { get }

    func startScan()
    func stopScan()
    func connect(to uuid: UUID, _ completion: @escaping (Result<ChatHostConnection, Error>) -> Void)
}
