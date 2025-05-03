import SwiftUI
class ChatViewModelSingleton: ObservableObject {
    static let shared = DeepSeekViewModel()
    var vm: DeepSeekViewModel?
    @Published var chatViewModel = DeepSeekViewModel()
    private init() {} // private constructor keeps singleton
}
struct AiChatView: View {
    @StateObject private var viewModelManager = ChatViewModelSingleton.shared
        @ObservedObject private var chatViewModel: DeepSeekViewModel
        @Environment(\.dismiss) private var dismiss
        @State private var messageText: String = ""
        
        init() {
            self.chatViewModel = ChatViewModelSingleton.shared.getViewModel()
        }
        
        var body: some View {
            VStack {
                // Navigation bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    Text("Your AI Assistant")
                        .font(.headline)
                    Spacer()
                }
                .padding()
                
                // Message list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(chatViewModel.messages) { message in
                            MessageBubble(message: message)
                        }
                        
                        if chatViewModel.isLoading {
                            HStack {
                                ProgressView()
                                    .padding()
                                Text("Thinking...")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                }
                
                // Error message
                if let error = chatViewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                        .multilineTextAlignment(.center)
                }
                
                // Input area
                HStack {
                    TextField("Input your message...", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(chatViewModel.isLoading)
                    
                    Button(action: {
                        guard !messageText.isEmpty else { return }
                        let text = messageText
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
