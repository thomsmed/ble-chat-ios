//
//  ChatBubbleView.swift
//  BLEChat
//
//  Created by Thomas Asheim Smedmann on 19/11/2023.
//

import SwiftUI

struct ChatBubbleView: View {
    let message: String
    let incoming: Bool

    var body: some View {
        VStack {
            HStack {
                if incoming {
                    Text(message)
                    Spacer()
                } else {
                    Spacer()
                    Text(message)
                }
            }
            .padding()
            .background {
                Color(uiColor: .secondarySystemBackground)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(incoming ? .trailing : .leading, 48)
        }
    }
}

#Preview {
    ChatBubbleView(message: "Hello from Host", incoming: true)
}

#Preview {
    ChatBubbleView(message: "Hello from Guest", incoming: false)
}

#Preview {
    ScrollView {
        ChatBubbleView(message: "Hello from Host", incoming: true)
        ChatBubbleView(message: "Hello from Guest", incoming: false)
    }
}
