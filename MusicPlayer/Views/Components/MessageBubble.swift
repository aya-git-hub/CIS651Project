//
//  MessageBubble.swift
//  MusicPlayer
//
//  Created by yuao ai on 4/23/25.
//  Copyright © 2025 London App Brewery. All rights reserved.
//

import Foundation
import SwiftUI
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            Text(message.content)
                .padding()
                .background(message.isUser ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(message.isUser ? .white : .primary)
                .cornerRadius(15)
                .textSelection(.enabled)
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}
