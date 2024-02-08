//
//  JoinChatView.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 19/11/2023.
//

import SwiftUI

struct JoinChatView: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8, pinnedViews: [.sectionHeaders]) {
                ForEach(viewModel.chatHostSections) { chatHostSection in
                    Section {
                        ForEach(chatHostSection.chatHosts) { chatHost in
                            VStack {
                                Text(chatHost.name)
                                    .font(.headline)
                                HStack {
                                    Text("Last seen:")
                                    Text(chatHost.lastSeen, style: .time)
                                }
                                .font(.subheadline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background {
                                Color(uiColor: .secondarySystemBackground)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .onTapGesture {
                                viewModel.didSelect(chatHost.name, withId: chatHost.id)
                            }
                        }
                    } header: {
                        Text(chatHostSection.title)
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .foregroundStyle(.secondary)
                            .background {
                                Color(uiColor: .systemBackground)
                            }
                    }
                }
            }
            .padding()
            .animation(.bouncy, value: viewModel.viewUpdateTrigger)
            .background {
                Color(uiColor: .systemBackground)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()

                if viewModel.isScanning {
                    ProgressView()
                }

                Spacer()
            }
        }
        .navigationTitle("Who to chat with?")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: viewModel.didAppear)
        .onDisappear(perform: viewModel.didDisappear)
    }
}

#Preview {
    MainActor.assumeIsolated {
        JoinChatView(viewModel: .init(
            chatHostScanner: PreviewAppDependencies.shared.chatHostScanner,
            onEvent: { _ in }
        ))
    }
}
