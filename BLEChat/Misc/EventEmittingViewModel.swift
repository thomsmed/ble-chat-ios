//
//  EventEmittingViewModel.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 26/12/2023.
//

import Foundation

class EventEmittingViewModel<Event> {
    internal var onEvent: (Event) -> Void

    init(onEvent: @escaping (Event) -> Void) {
        self.onEvent = onEvent
    }
}
