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
            print("DeepSeekViewModel: I was init")
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
    private let retryDelay: UInt64 = 2_000_000_000 // 2 秒

    /// 发送一条消息到 DeepSeek Chat 模型
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
                                userInfo: [NSLocalizedDescriptionKey: "无效的模型地址"])
                }

                // 构造请求
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                // 构造消息历史
                let messageHistory = messages.map { message in
                    [
                        "role": message.isUser ? "user" : "assistant",
                        "content": message.content
                    ]
                }

                // 构造请求体
                let body: [String: Any] = [
                    "model": "deepseek-chat",
                    "messages": messageHistory,
                    "temperature": 0.7,
                    "max_tokens": 1000,
                    "top_p": 0.9,
                    "stream": false
                ]
                
                request.httpBody = try JSONSerialization.data(withJSONObject: body)

                // 发起请求
                let (data, response) = try await URLSession.shared.data(for: request)

                // 调试：打印原始响应
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
                                    userInfo: [NSLocalizedDescriptionKey: "未解析到有效回复"])
                    }

                    await MainActor.run {
                        messages.append(ChatMessage(content: reply, isUser: false))
                        isLoading = false
                    }
                    return

                case 401:
                    throw NSError(domain: "DeepSeek", code: 401,
                                userInfo: [NSLocalizedDescriptionKey: "API Key 无效，请检查您的 API Key"])
                case 429:
                    throw NSError(domain: "DeepSeek", code: 429,
                                userInfo: [NSLocalizedDescriptionKey: "请求过于频繁，请稍后再试"])
                case 503:
                    if attempt < maxRetries {
                        try await Task.sleep(nanoseconds: retryDelay)
                        continue
                    }
                    throw NSError(domain: "DeepSeek", code: 503,
                                userInfo: [NSLocalizedDescriptionKey: "服务器暂时不可用，请稍后再试"])
                default:
                    let bodyStr = String(data: data, encoding: .utf8) ?? ""
                    throw NSError(domain: "DeepSeek", code: http.statusCode,
                                userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode)：\(bodyStr)"])
                }
            } catch {
                // 最后一次重试失败时反馈错误
                if attempt == maxRetries {
                    await MainActor.run {
                        errorMessage = "请求失败：\(error.localizedDescription)"
                        isLoading = false
                    }
                }
            }
        }
    }

    /// 用于解析 DeepSeek 返回的 JSON
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
