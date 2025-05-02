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
    /*
     @StateObject only makes sure a view owns the same viewmodel, hence, we need singleton to make sure each view holds the same instance when some views have the same viewmodel.
     */
    @StateObject var authViewModel = AuthViewModel.getAuth()
    @StateObject var downloadVM = DownloadPlayViewModel.getDownloadPlay()
    @StateObject var playerViewModel = PlayerTestViewModel()
    
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if authViewModel.isLoggedIn {
                MainView(viewModel: playerViewModel)
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
