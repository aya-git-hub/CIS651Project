import SwiftUI
import Firebase

@main
struct LoginApp: App {
    init() {
        FirebaseApp.configure() // 初始化 Firebase
        print("FirebaseApp successfully configured!")
    }

    var body: some Scene {
        WindowGroup {
            LogInView()
                .environmentObject(AuthViewModel()) // ViewModel 注入
        }
    }
}
