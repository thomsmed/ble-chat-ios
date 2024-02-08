//
//  CoreBluetoothChatHostScanner.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 19/11/2023.
//

import Foundation
import Combine
import CoreBluetooth

// MARK: CBManagerState+asCHSState

fileprivate extension CBManagerState {
    var asCHSState: ChatHostScannerState {
        switch self {
            case .poweredOn:
                return .ready
            case .unauthorized:
                return .unauthorised
            default:
                return .off
        }
    }
}

// MARK: CoreBluetoothChatHostScanner

final class CoreBluetoothChatHostScanner: NSObject {
    private lazy var serialQueue = DispatchQueue(
        label: "\(String(describing: Self.self)).\(String(describing: DispatchQueue.self))",
        qos: .userInitiated,
        attributes: [],
        target: .global(qos: .userInitiated)
    )

    private lazy var centralManager = CBCentralManager(
        delegate: self,
        queue: serialQueue
    )

    private lazy var stateSubject = CurrentValueSubject<ChatHostScannerState, Never>(
        centralManager.state.asCHSState
    )

    private let discoveriesSubject = PassthroughSubject<ChatHostDiscovery, Never>()
    private var discoveredPeripherals: [CBPeripheral] = []

    private var chatHostConnectionCompletion: ((Result<ChatHostConnection, Error>) -> Void)?
    private var activeChatHostConnection: CoreBluetoothChatHostConnection?
}

// MARK: CBCentralManagerDelegate

extension CoreBluetoothChatHostScanner: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(
        _ central: CBCentralManager
    ) {
        stateSubject.send(central.state.asCHSState)
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber
    ) {
        // Note: If the device has been connected to before,
        // it might have been assigned a different name than first specified in the advertisement data.
        if let index = discoveredPeripherals.firstIndex(where: { discoveredPeripheral in
            discoveredPeripheral == peripheral
        }) {
            discoveredPeripherals[index] = peripheral
            let chatBroadcastingName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
            discoveriesSubject.send(.rediscovered(
                DiscoveredChatHost(
                    name: chatBroadcastingName ?? peripheral.name,
                    uuid: peripheral.identifier,
                    lastSeen: .now
                )
            ))
        } else {
            discoveredPeripherals.append(peripheral)
            let chatBroadcastingName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
            discoveriesSubject.send(.discovered(
                DiscoveredChatHost(
                    name: chatBroadcastingName ?? peripheral.name,
                    uuid: peripheral.identifier,
                    lastSeen: .now
                )
            ))
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        let coreBluetoothChatHostConnection = CoreBluetoothChatHostConnection(
            serialQueue: serialQueue,
            centralManager: centralManager
        )
        coreBluetoothChatHostConnection.connected(to: peripheral)
        activeChatHostConnection = coreBluetoothChatHostConnection

        chatHostConnectionCompletion?(.success(coreBluetoothChatHostConnection))
        chatHostConnectionCompletion = nil
    }

    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        chatHostConnectionCompletion?(.failure(error ?? ChatHostError.connectionFailure))
        chatHostConnectionCompletion = nil
    }

    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        activeChatHostConnection?.disconnected(from: peripheral, with: error)
        activeChatHostConnection = nil
    }
}

// MARK: ChatHostScanner

extension CoreBluetoothChatHostScanner: ChatHostScanner {
    var state: AnyPublisher<ChatHostScannerState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    var discoveries: AnyPublisher<ChatHostDiscovery, Never> {
        discoveriesSubject.eraseToAnyPublisher()
    }

    var isScanning: Bool {
        stateSubject.value == .scanning
    }

    func startScan() {
        serialQueue.async {
            guard self.stateSubject.value == .ready else { return }
            self.stateSubject.send(.scanning)
            self.discoveredPeripherals = []
            // Scans for peripherals that provides all the specified services.
            self.centralManager.scanForPeripherals(
                withServices: [
                    AssignedNumbers.chatService
                ],
                options: nil
                // options: [CBCentralManagerScanOptionAllowDuplicatesKey: true] // Will produce a discovery event with every Peripheral advertisement.
            )
        }
    }

    func stopScan() {
        serialQueue.async {
            guard self.stateSubject.value == .scanning else { return }
            self.stateSubject.send(.ready)
            self.centralManager.stopScan()
        }
    }

    func connect(to uuid: UUID, _ completion: @escaping (Result<ChatHostConnection, Error>) -> Void) {
        serialQueue.async {
            guard
                self.stateSubject.value == .ready || self.stateSubject.value == .scanning
            else {
                return completion(.failure(ChatHostError.invalidState))
            }

            // Make sure any previous connection is canceled.
            self.activeChatHostConnection?.disconnect()

            guard let peripheral = self.discoveredPeripherals.first(where: { discoveredPeripheral in
                discoveredPeripheral.identifier == uuid
            }) else {
                return completion(.failure(ChatHostError.unknownPeripheral))
            }

            // Make sure any previous completion handler is called.
            self.chatHostConnectionCompletion?(.failure(ChatHostError.connectionFailure))

            self.chatHostConnectionCompletion = completion
            self.centralManager.connect(peripheral, options: nil)
        }
    }
}
