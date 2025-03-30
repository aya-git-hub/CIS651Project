//
//  SignupViewModel.swift
//  Login
//
//  Created by Pengfei Liu on 3/28/25.
//

import Foundation
import SwiftUI
import Combine

class SignUpViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var birthday1: String = "" // 添加字符串形式的生日
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let databaseManager = UserManager()
    
    // 将生日字符串转换为Date
    private var birthday: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let birthdayDate = dateFormatter.date(from: birthday1)
        if let validBirthday = birthdayDate {
            return validBirthday
        } else {
            return Date()
        }
    }
    
    // 验证输入
    private func validateInputs() -> Bool {
        // 检查是否为空
        guard !name.isEmpty, !birthday1.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "所有字段都不能为空"
            return false
        }
        
        // 验证邮箱格式
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES[c] %@", emailRegex)
        guard emailPredicate.evaluate(with: email) else {
            errorMessage = "请输入有效的邮箱地址"
            return false
        }
        
        // 检查密码是否匹配
        guard password == confirmPassword else {
            errorMessage = "两次输入的密码不一致"
            return false
        }
        
        // 检查密码强度
        guard password.count >= 6 else {
            errorMessage = "密码必须至少6个字符长"
            return false
        }
        
        // 验证生日格式和有效性
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        guard let parsedBirthday = dateFormatter.date(from: birthday1) else {
            errorMessage = "请输入有效的生日格式 (MM-dd-yyyy)"
            return false
        }
        
        guard parsedBirthday <= Date() else {
            errorMessage = "请选择有效的生日"
            return false
        }
        
        return true
    }
    
    // 注册
    func signUp() -> Bool {
        guard validateInputs() else {
            showError = true
            return false
        }
        
        // 检查邮箱是否已存在
        if databaseManager.isEmailExists(email) {
            errorMessage = "该邮箱已被注册"
            showError = true
            return false
        }
        
        // 创建用户
        let newUser = User(name: name, email: email, password: password, birthday: birthday)
        
        // 插入数据库
        if databaseManager.insertUser(newUser) {
            // 清空输入
            name = ""
            email = ""
            birthday1 = ""
            password = ""
            confirmPassword = ""

            return true
        } else {
            errorMessage = "注册失败，请重试"
            showError = true
            return false
        }
    }
}
