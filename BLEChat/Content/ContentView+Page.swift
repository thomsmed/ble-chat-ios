//
//  ContentView+Page.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 19/11/2023.
//

import SwiftUI

extension ContentView {
    enum Page: Identifiable, Hashable {
        case hostChat
        case joinChat
        case guestChat(chatHostName: String, chatHostId: UUID)

        var id: Self {
            self
        }
    }
}
