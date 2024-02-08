//
//  HomeView+ViewModel.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 19/11/2023.
//

import SwiftUI
import Combine

extension HomeView {
    @MainActor final class ViewModel: EventEmittingViewModel<Event>, ObservableObject {
        private let appDependencies: AppDependencies

        init(
            appDependencies: some AppDependencies,
            onEvent: @escaping (Event) -> Void
        ) {
            self.appDependencies = appDependencies
            super.init(onEvent: onEvent)
        }
    }
}

extension HomeView.ViewModel {
    func didTapHost() {
        onEvent(.didTapHost)
    }

    func didTapJoin() {
        onEvent(.didTapJoin)
    }
}
