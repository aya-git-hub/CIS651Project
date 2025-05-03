import Foundation
import SwiftUI


class DeepSeekViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var chatViewModel:DeepSeekViewModel?
    public func getViewModel() -> DeepSeekViewModel {
        if chatViewModel == nil {
            chatViewModel = DeepSeekViewModel()
            print("DeepSeekViewModel: Initialized")
            return chatViewModel!;
        }
        else{
            print("DeepSeekViewModel: I already exist")
            return chatViewModel!
        }
        
    }

    private var apiKey: String {
           Configuration.deepseekApiKey
       }
    private let modelEndpoint = "https://api.deepseek.com/v1/chat/completions"
    private let maxRetries = 3
    private let retryDelay: UInt64 = 2_000_000_000 // 2 seconds

    /// Send a message to the DeepSeek Chat model
    func sendMessage(_ text: String) async {
        await MainActor.run {
            errorMessage = nil
            isLoading = true
            messages.append(ChatMessage(content: text, isUser: true))
        }

        for attempt in 1...maxRetries {
            do {
                guard let url = URL(string: modelEndpoint) else {
                    throw NSError(domain: "DeepSeek", code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "Invalid model endpoint"])
                }

                // Construct request
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                // Construct message history
                let messageHistory = messages.map { message in
                    [
                        "role": message.isUser ? "user" : "assistant",
                        "content": message.content
                    ]
                }

                // Construct request body
                let body: [String: Any] = [
                    "model": "deepseek-chat",
                    "messages": messageHistory,
                    "temperature": 0.7,
                    "max_tokens": 1000,
                    "top_p": 0.9,
                    "stream": false
                ]
                
                request.httpBody = try JSONSerialization.data(withJSONObject: body)

                // Send request
                let (data, response) = try await URLSession.shared.data(for: request)

                // Debug: print raw response
                if let raw = String(data: data, encoding: .utf8) {
                    print("🌐 DeepSeek raw response: \(raw)")
                }

                guard let http = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }

                switch http.statusCode {
                case 200:
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(DeepSeekResponse.self, from: data)
                    
                    guard let reply = response.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines),
                          !reply.isEmpty else {
                        throw NSError(domain: "DeepSeek", code: -1,
                                    userInfo: [NSLocalizedDescriptionKey: "No valid response parsed"])
                    }

                    await MainActor.run {
                        messages.append(ChatMessage(content: reply, isUser: false))
                        isLoading = false
                    }
                    return

                case 401:
                    throw NSError(domain: "DeepSeek", code: 401,
                                userInfo: [NSLocalizedDescriptionKey: "Invalid API Key, please check your API Key"])
                case 429:
                    throw NSError(domain: "DeepSeek", code: 429,
                                userInfo: [NSLocalizedDescriptionKey: "Too many requests, please try again later"])
                case 503:
                    if attempt < maxRetries {
                        try await Task.sleep(nanoseconds: retryDelay)
                        continue
                    }
                    throw NSError(domain: "DeepSeek", code: 503,
                                userInfo: [NSLocalizedDescriptionKey: "Server temporarily unavailable, please try again later"])
                default:
                    let bodyStr = String(data: data, encoding: .utf8) ?? ""
                    throw NSError(domain: "DeepSeek", code: http.statusCode,
                                userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(bodyStr)"])
                }
            } catch {
                // Report error on last retry failure
                if attempt == maxRetries {
                    await MainActor.run {
                        errorMessage = "Request failed: \(error.localizedDescription)"
                        isLoading = false
                    }
                }
            }
        }
    }

    /// Used for parsing DeepSeek's JSON response
    private struct DeepSeekResponse: Codable {
        let choices: [Choice]
        
        struct Choice: Codable {
            let message: Message
            
            struct Message: Codable {
                let content: String
                let role: String
            }
        }
    }
}
