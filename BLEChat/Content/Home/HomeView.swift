//
//  HomeView.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 19/11/2023.
//

import SwiftUI
import Combine

struct HomeView: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        VStack {
            Text("A Bluetooth Low Energy and Core Bluetooth showcasing app")
                .font(.title)
                .padding()

            Spacer()

            Button {
                viewModel.didTapHost()
            } label: {
                Text("Host")
                    .font(.system(size: 24, weight: .medium))
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .padding()

            Button {
                viewModel.didTapJoin()
            } label: {
                Text("Join")
                    .font(.system(size: 24, weight: .medium))
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .padding()

            Spacer()
        }
        .navigationTitle("BLE Chat")
    }
}

#Preview {
    MainActor.assumeIsolated {
        HomeView(viewModel: .init(
            appDependencies: PreviewAppDependencies.shared,
            onEvent: { _ in }
        ))
    }
}
