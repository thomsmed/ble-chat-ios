//
//  ChatServiceFactory.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 19/11/2023.
//

import Foundation
import CoreBluetooth

enum ChatServiceFactory {

    /// The Attribute value for the Descriptor 'Characteristic Presentation Format'
    ///
    /// Used as a Descriptor for the Incoming Reactions Characteristic and Outgoing Reactions Characteristic.
    ///
    /// | Format | Exponent | Unit | Name Space | Description |
    /// | 16 bit | 16 bit | 16 + 16 bit | 16 bit | 16 + 16 bit |
    ///
    /// More Info in the Core BLE Specification: https://www.bluetooth.com/specifications/specs/core-specification/,
    /// chapter 3.3.3.5 - Characteristic Presentation Format
    private static let characteristicFormatStringValue: [UInt8] = [
        0x19,       // Format: UTF8.
        0x00,       // Exponent: 0 (not used for the UTF8 format).
        0x27, 0x00, // Unit (4 bytes): undefined (text has no unit).
        0x00,       // Name Space (Aka organisation): none.
        0x00, 0x00  // Description (a custom value defined by the organisation in Name Space): none.
    ]

    /// Our Incoming Reaction Characteristic. Associated with our Chat Service.
    ///
    /// This is a writeable (without acknowledge response from peripheral), non-encrypted characteristic.
    static let incomingReactionCharacteristic: CBMutableCharacteristic = {
        let characteristic = CBMutableCharacteristic(
            type: AssignedNumbers.chatServiceIncomingReactionsCharacteristic,
            properties: [.write, .writeWithoutResponse],
            // Dynamic value (`value = nil`).
            // Will require implementation of CBPeripheralManagerDelegate.peripheralManager(_:, didReceiveRead:)
            value: nil,
            permissions: [.writeable] // Do not require encryption
        )
        characteristic.descriptors = [
            CBMutableDescriptor(
                type: CBUUID(string: CBUUIDCharacteristicUserDescriptionString),
                value: "IncomingReactions"
            ),
            CBMutableDescriptor(
                type: CBUUID(string: CBUUIDCharacteristicFormatString),
                value: Data(characteristicFormatStringValue)
            )
        ]
        return characteristic
    }()

    /// Our Outgoing Reaction Characteristic. Associated with our Chat Service.
    ///
    /// This is a readable, non-encrypted characteristic.
    /// With the possibility of emitting notifications about its value (without acknowledge response from central).
    static let outgoingReactionsCharacteristic: CBMutableCharacteristic = {
        let characteristic = CBMutableCharacteristic(
            type: AssignedNumbers.chatServiceOutgoingReactionsCharacteristic,
            properties: [.read, .notify],
            // Dynamic value (`value = nil`).
            // Will require implementation of CBPeripheralManagerDelegate.peripheralManager(_:, didReceiveRead:)
            value: nil,
            permissions: [.readable] // Do not require encryption
        )
        characteristic.descriptors = [
            CBMutableDescriptor(
                type: CBUUID(string: CBUUIDCharacteristicUserDescriptionString),
                value: "OutgoingReactions"
            ),
            CBMutableDescriptor(
                type: CBUUID(string: CBUUIDCharacteristicFormatString),
                value: Data(characteristicFormatStringValue)
            )
        ]
        return characteristic
    }()

    /// Make a CBService representing our Chat Service.
    ///
    /// Also associate an already open L2CAP channel (via its PSM)  with our Chat Service, and make its PSM available as a discoverable characteristic.
    /// The PSM is needed in order for others to be able to write and read over the open L2CAP channel.
    static func makeChatService(with psm: CBL2CAPPSM) -> CBMutableService {
        let mutableService = CBMutableService(type: AssignedNumbers.chatService, primary: true)
        let l2capPSMCharacteristic = CBMutableCharacteristic(
            type: AssignedNumbers.chatServiceL2CAPPSMCharacteristic,
            properties: [.read],
            // Static value (`value != nil`).
            // Do not require implementation of CBPeripheralManagerDelegate.peripheralManager(_:, didReceiveRead:)
            value: Data(withUnsafeBytes(of: psm, Array.init)), // UInt16 / CBL2CAPPSM as Data.
            permissions: [.readEncryptionRequired] // Require encryption
        )
        // Note: GATT service characteristic descriptors are not really required (it depends on the use case),
        // so we'll skip adding descriptors for our L2CAP PSM characteristic
        mutableService.characteristics = [
            ChatServiceFactory.incomingReactionCharacteristic,
            ChatServiceFactory.outgoingReactionsCharacteristic,
            l2capPSMCharacteristic
        ]
        return mutableService
    }
}
