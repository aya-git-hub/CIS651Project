import SwiftUI

struct HuggingFaceChatView: View {
    @StateObject private var chatViewModel = HuggingFaceChatViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var messageText: String = ""
    
    var body: some View {
        VStack {
            // 导航栏
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                Text("AI 助手")
                    .font(.headline)
                Spacer()
            }
            .padding()
            
            // 消息列表
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(chatViewModel.messages) { message in
                        MessageBubble(message: message)
                    }
                    
                    if chatViewModel.isLoading {
                        HStack {
                            ProgressView()
                                .padding()
                            Text("思考中...")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
            }
            
            // 错误信息
            if let error = chatViewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
                    .multilineTextAlignment(.center)
            }
            
            // 输入区域
            HStack {
                TextField("输入消息...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(chatViewModel.isLoading)
                
                Button(action: {
                    guard !messageText.isEmpty else { return }
                    let text = messageText
                    chatViewModel.messages.append(ChatMessage(content: text, isUser: true))
                    messageText = ""
                    
                    Task {
                        await chatViewModel.sendMessage(text)
                    }
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(messageText.isEmpty || chatViewModel.isLoading ? .gray : .blue)
                }
                .disabled(messageText.isEmpty || chatViewModel.isLoading)
            }
            .padding()
        }
    }
}

// 消息气泡组件


