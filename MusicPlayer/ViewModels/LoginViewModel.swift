//
//  LoginViewModel.swift
//  Login
//
//  Created by Pengfei Liu on 3/28/25.
//

import Foundation
import SwiftUI
import Combine

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let databaseManager = UserManager()
    
    // 登录验证，返回是否登录成功
    func login() -> Bool {
        // 检查输入是否为空
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "邮箱和密码不能为空"
            showError = true
            return false
        }
        
        // 验证邮箱格式
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: email) else {
            errorMessage = "请输入有效的邮箱地址"
            showError = true
            return false
        }
        
        // 验证用户
        if databaseManager.validateUser(email: email, password: password) {
            return true
        } else {
            errorMessage = "邮箱或密码错误"
            showError = true
            return false
        }
    }
}
