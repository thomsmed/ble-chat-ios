//
//  PreviewAppDependencies.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 19/11/2023.
//

import Foundation

final class PreviewAppDependencies: AppDependencies {
    static let shared: AppDependencies = PreviewAppDependencies()

    let chatHost: ChatHost
    let chatHostScanner: ChatHostScanner

    private init() {
        chatHost = PreviewChatHost()
        chatHostScanner = PreviewChatHostScanner()
    }
}
