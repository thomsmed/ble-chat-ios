//
//  JoinChatView+Event.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 23/11/2023.
//

import Foundation

extension JoinChatView {
    enum Event {
        case didSelectHost(chatHostName: String, chatHostId: UUID)
    }
}
