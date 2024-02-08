//
//  GuestChatView+Section.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 22/11/2023.
//

import Foundation
import SwiftUI

extension GuestChatView {
    struct ChatSection: Identifiable {
        struct ChatMessage: Identifiable {
            let id = UUID()
            let message: String
            let incoming: Bool
        }

        let id = UUID()
        let title: LocalizedStringKey
        var chatMessages: [ChatMessage]
    }
}
