//
//  JoinChatView+ChatHostSection.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 22/11/2023.
//

import Foundation
import SwiftUI

extension JoinChatView {
    struct ChatHostSection: Identifiable {
        struct ChatHost: Identifiable {
            let id: UUID
            let name: String
            let lastSeen: Date
        }

        let id = UUID()
        let title: LocalizedStringKey
        var chatHosts: [ChatHost]
    }

}
