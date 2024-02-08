//
//  HostChatView.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 19/11/2023.
//

import SwiftUI

struct HostChatView: View {
    private struct AnimationValues {
        var scale = 0.0
        var opacity = 1.0
        var verticalTransition = 0.0
        var horizontalTransition = 0.0
    }

    @StateObject var viewModel: ViewModel

    @Namespace var bottomId

    var body: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                LazyVStack(spacing: 8, pinnedViews: [.sectionHeaders]) {
                    ForEach(viewModel.chatSections) { chatSection in
                        Section {
                            ForEach(chatSection.chatMessages) { chatMessage in
                                ChatBubbleView(
                                    message: chatMessage.message,
                                    incoming: chatMessage.incoming
                                )
                            }
                        } header: {
                            Text(chatSection.title)
                                .frame(maxWidth: .infinity)
                                .padding(8)
                                .foregroundStyle(.secondary)
                                .background {
                                    Color(uiColor: .systemBackground)
                                }
                        }
                    }

                    Spacer().id(bottomId) // Only used as an anchor point for scrolling.
                }
                .padding()
                .animation(.bouncy, value: viewModel.viewUpdateTrigger)
                .background {
                    Color(uiColor: .systemBackground)
                }
            }
            .onChange(of: viewModel.viewUpdateTrigger) {
                withAnimation(.bouncy) {
                    scrollViewProxy.scrollTo(bottomId, anchor: .bottom)
                }
            }
            .overlay(alignment: .bottomLeading) {
                Text(viewModel.incomingReaction)
                    .keyframeAnimator(
                        initialValue: AnimationValues(),
                        trigger: viewModel.incomingReactionTrigger
                    ) { content, value in
                        content
                            .scaleEffect(value.scale)
                            .opacity(value.opacity)
                            .offset(
                                x: value.horizontalTransition,
                                y: value.verticalTransition
                            )
                    } keyframes: { _ in
                        KeyframeTrack(\.scale) {
                            SpringKeyframe(3.0, duration: 0.15, spring: .bouncy)
                            SpringKeyframe(0.0)
                        }
                        KeyframeTrack(\.opacity) {
                            SpringKeyframe(1.0, duration: 0.15, spring: .bouncy)
                            SpringKeyframe(0.0)
                        }
                        KeyframeTrack(\.horizontalTransition) {
                            SpringKeyframe(50.0, duration: 0.25, spring: .bouncy)
                        }
                        KeyframeTrack(\.verticalTransition) {
                            SpringKeyframe(-50.0, duration: 0.25, spring: .bouncy)
                        }
                    }
            }
        }
        .safeAreaInset(edge: .bottom) {
            ChatInputView(
                reaction: viewModel.reaction,
                message: viewModel.message
            ) {
                viewModel.sendMessage()
            }
            .padding()
            .background {
                Color(uiColor: .systemBackground)
            }
        }
        .navigationTitle("Chat (Hosting)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: viewModel.didAppear)
        .onDisappear(perform: viewModel.didDisappear)
    }
}

#Preview {
    MainActor.assumeIsolated {
        HostChatView(viewModel: .init(
            chatHost: PreviewAppDependencies.shared.chatHost
        ))
    }
}
