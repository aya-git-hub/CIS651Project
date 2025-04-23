//
//  LoginApp.swift
//  Login
//
//  Created by Pengfei Liu on 3/27/25.
//

import SwiftUI
import Firebase

@main
struct LoginApp: App {
    @StateObject var authViewModel = AuthViewModel.getAuth()
    @StateObject var downloadVM = DownloadPlayViewModel() // ✅ 新增

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if authViewModel.isLoggedIn {
                MainView()
                    .environmentObject(authViewModel)
                    .environmentObject(downloadVM) // ✅ 注入
            } else {
                LogInView()
                    .environmentObject(authViewModel)
                    .environmentObject(downloadVM) // ✅ 注入
            }
        }
    }
}
