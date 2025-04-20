//
//  AuthViewModel.swift
//  Login
//
//  Created by Pengfei Liu on 4/19/25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User? = Auth.auth().currentUser
    @Published var isLoggedIn: Bool = Auth.auth().currentUser != nil
    @Published var errorMessage: String = ""
    @Published var registrationSuccess = false

    func login(email: String, password: String) async {
        self.errorMessage = ""

        guard !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "邮箱和密码不能为空"
            self.isLoggedIn = false
            return
        }

        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.user = result.user
            self.isLoggedIn = true
            self.errorMessage = ""
            print("✅ 登录成功：\(result.user.email ?? "")")
        } catch {
            self.isLoggedIn = false

            if let err = error as NSError?,
               let code = AuthErrorCode(rawValue: err.code) {
                switch code {
                case .invalidEmail:
                    self.errorMessage = "邮箱格式不正确"
                case .userNotFound:
                    self.errorMessage = "该用户不存在"
                case .wrongPassword:
                    self.errorMessage = "密码不正确"
                case .networkError:
                    self.errorMessage = "网络错误，请检查网络连接"
                default:
                    self.errorMessage = "登录失败，请稍后再试"
                }
            } else {
                self.errorMessage = "登录失败，请稍后再试"
            }

            print("❌ 登录失败：\(error.localizedDescription)")
        }
    }



    func register(email: String, password: String, confirmPassword: String, name: String, birthday: String) async {
        // 1. 检查是否为空
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty, !name.isEmpty, !birthday.isEmpty else {
            self.errorMessage = "所有字段都不能为空"
            self.registrationSuccess = false
            return
        }

        // 2. 邮箱格式验证
        let emailRegex = #"^\S+@\S+\.\S+$"#
        guard email.range(of: emailRegex, options: .regularExpression) != nil else {
            self.errorMessage = "请输入有效的邮箱地址"
            self.registrationSuccess = false
            return
        }

        // 3. 密码一致性验证
        guard password == confirmPassword else {
            self.errorMessage = "两次输入的密码不一致"
            self.registrationSuccess = false
            return
        }

        // 4. 密码强度
        guard password.count >= 6 else {
            self.errorMessage = "密码必须至少6个字符长"
            self.registrationSuccess = false
            return
        }

        // 5. 生日格式验证
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        guard let parsedBirthday = formatter.date(from: birthday) else {
            self.errorMessage = "请输入有效的生日格式 (MM-dd-yyyy)"
            self.registrationSuccess = false
            return
        }

        // 6. 生日不能是未来
        guard parsedBirthday <= Date() else {
            self.errorMessage = "请选择有效的生日"
            self.registrationSuccess = false
            return
        }

        // 7. 邮箱是否已存在（交由 Firebase 处理）

        // 如果都通过了再尝试注册
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.user = nil
            self.isLoggedIn = false
            self.registrationSuccess = true
            self.errorMessage = ""
            print("✅ 注册成功：\(result.user.email ?? "")")
            
            // 🔥 Firestore 保存资料
            let db = Firestore.firestore()
            let uid = result.user.uid
            try await db.collection("users").document(uid).setData([
                "name": name,
                "birthday": birthday,
                "email": email
            ])
            print("✅ 用户信息保存到 Firestore")
            
        } catch let error as NSError {
            print("❌ 注册失败：\(error.localizedDescription)")

            if let code = AuthErrorCode(rawValue: error.code) {
                switch code {
                case .emailAlreadyInUse:
                    self.errorMessage = "该邮箱已被注册"
                case .invalidEmail:
                    self.errorMessage = "邮箱格式不正确"
                case .weakPassword:
                    self.errorMessage = "密码过于简单，至少6位"
                case .networkError:
                    self.errorMessage = "网络错误，请检查网络连接"
                default:
                    self.errorMessage = "注册失败，请稍后再试"
                }
            } else {
                self.errorMessage = "注册失败，请稍后再试"
            }

            self.registrationSuccess = false
        }
    
    }
    
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.isLoggedIn = false
        } catch {
            self.errorMessage = "退出登录失败：\(error.localizedDescription)"
        }
    }
}
