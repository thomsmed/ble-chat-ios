//
//  AppDependencies.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 19/11/2023.
//

import Foundation

protocol AppDependencies: AnyObject {
    var chatHost: ChatHost { get }
    var chatHostScanner: ChatHostScanner { get }
}

final class DefaultAppDependencies: AppDependencies {
    let chatHost: ChatHost
    let chatHostScanner: ChatHostScanner

    init(deviceName: String) {
        chatHost = CoreBluetoothChatHost(chatBroadcastingName: deviceName)
        chatHostScanner = CoreBluetoothChatHostScanner()
    }
}
