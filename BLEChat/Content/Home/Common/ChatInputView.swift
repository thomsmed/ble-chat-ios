//
//  File.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 20/11/2023.
//

import SwiftUI

private struct ChatReactionView: View {
    private struct AnimationValues {
        var scale = 1.0
        var verticalTransition = 0.0
    }

    @State var animationTrigger: Bool = false

    let reaction: String

    let action: () -> Void

    var body: some View {
        Button {
            action()

            animationTrigger.toggle()
        } label: {
            Text(reaction)
                .keyframeAnimator(
                    initialValue: AnimationValues(),
                    trigger: animationTrigger
                ) { content, value in
                    content
                        .scaleEffect(value.scale)
                        .offset(y: value.verticalTransition)
                } keyframes: { _ in
                    KeyframeTrack(\.scale) {
                        SpringKeyframe(2.0, duration: 0.25, spring: .bouncy)
                        SpringKeyframe(1.0)
                    }
                    KeyframeTrack(\.verticalTransition) {
                        SpringKeyframe(-50.0, duration: 0.25, spring: .bouncy)
                        SpringKeyframe(0.0)
                    }
                }
        }
    }
}

struct ChatInputView: View {
    private static let reactions: [String] = ["❤️", "🥺", "😱", "👏", "🙂", "🤣"]

    @Binding var reaction: String?
    @Binding var message: String

    let action: () -> Void

    var body: some View {
        VStack {
            Grid {
                GridRow {
                    ForEach(Self.reactions, id: \.self) { reaction in
                        ChatReactionView(reaction: reaction) {
                            self.reaction = reaction
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }

            HStack {
                TextField(
                    "Write something...",
                    text: $message
                )
                .textFieldStyle(.roundedBorder)

                Button {
                    action()
                } label: {
                    Text("Send")
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

#Preview {
    ScrollView {

    }
    .safeAreaInset(edge: .bottom) {
        ChatInputView(
            reaction: .constant("❤️"),
            message: .constant(""),
            action: { }
        )
    }
}
