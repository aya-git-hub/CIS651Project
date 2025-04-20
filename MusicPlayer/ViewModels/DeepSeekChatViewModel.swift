import Foundation
import SwiftUI

/// 简单的消息模型
struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
}

class HuggingFaceChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    
    private let modelEndpoint = "https://api-inference.huggingface.co/models/distilgpt2"
    private let maxRetries = 3
    private let retryDelay: UInt64 = 2_000_000_000 // 2秒

    func sendMessage(_ text: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            messages.append(.init(content: text, isUser: true))
        }

        for attempt in 1...maxRetries {
            do {
                guard let url = URL(string: modelEndpoint) else {
                    throw NSError(domain: "HuggingFace", code: -1, userInfo: [NSLocalizedDescriptionKey: "无效的模型地址"])
                }

                let prompt = """
                [INST] <<SYS>>
                You are a helpful assistant.
                <</SYS>>
                \(text)
                [/INST]
                """

                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                let body: [String: Any] = [
                    "inputs": prompt,
                    "parameters": [
                        "max_new_tokens": 500,
                        "temperature": 0.7,
                        "top_p": 0.9
                    ]
                ]

                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let http = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }

                switch http.statusCode {
                case 200:
                    if let arr = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
                       let generated = arr.first?["generated_text"] as? String {
                        let reply = generated.components(separatedBy: "[/INST]").last?.trimmingCharacters(in: .whitespacesAndNewlines) ?? generated
                        await MainActor.run {
                            messages.append(.init(content: reply, isUser: false))
                            isLoading = false
                        }
                        return
                    } else {
                        throw NSError(
                            domain: "HuggingFace",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "无法解析返回内容"]
                        )
                    }
                case 401:
                    throw NSError(
                        domain: "HuggingFace",
                        code: 401,
                        userInfo: [NSLocalizedDescriptionKey: "API Key 无效，请检查您的 API Key"]
                    )
                case 429:
                    throw NSError(
                        domain: "HuggingFace",
                        code: 429,
                        userInfo: [NSLocalizedDescriptionKey: "请求过于频繁，请稍后再试"]
                    )
                case 503:
                    if attempt < maxRetries {
                        try? await Task.sleep(nanoseconds: retryDelay)
                        continue
                    }
                    throw NSError(
                        domain: "HuggingFace",
                        code: 503,
                        userInfo: [NSLocalizedDescriptionKey: "服务器暂时不可用，请稍后再试"]
                    )
                default:
                    let bodyStr = String(data: data, encoding: .utf8) ?? ""
                    throw NSError(
                        domain: "HuggingFace",
                        code: http.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode)：\(bodyStr)"]
                    )
                }
            } catch {
                if attempt == maxRetries {
                    await MainActor.run {
                        errorMessage = "请求失败：\(error.localizedDescription)"
                        isLoading = false
                    }
                }
            }
        }
    }
}
