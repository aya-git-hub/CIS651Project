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
    @Published var user: User? = Auth.auth().currentUser {
        didSet {
            if user != nil {
                Task {
                    await reloadUserProfile()
                }
            } else {
                currentUserProfile = nil
            }
        }
    }
    @Published var isLoggedIn: Bool = Auth.auth().currentUser != nil
    @Published var errorMessage: String = ""
    @Published var registrationSuccess = false
    @Published var currentUserProfile: UserProfile?
    
    
    
    static var avm: AuthViewModel?
    private init() {
        Task { await reloadUserProfile() }
    }
    //Singleton, make sure only one AuthViewModel exists
    public static func getAuth() -> AuthViewModel {
        if avm == nil {
            print("AuthViewModel: Initialized")
            avm =  AuthViewModel();
            return avm!;
        }
        else{
            print("AuthViewModel: I already exist")
            return avm!;
        }
        
    }

    func login(email: String, password: String) async {
        self.errorMessage = ""

        guard !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "Email and password cannot be empty"
            self.isLoggedIn = false
            return
        }

        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.user = result.user
            self.isLoggedIn = true
            self.errorMessage = ""
            print("✅ Login successful: \(result.user.email ?? "")")
        } catch {
            self.isLoggedIn = false

            if let err = error as NSError?,
               let code = AuthErrorCode(rawValue: err.code) {
                switch code {
                case .invalidEmail:
                    self.errorMessage = "Invalid email format"
                case .userNotFound:
                    self.errorMessage = "User not found"
                case .wrongPassword:
                    self.errorMessage = "Wrong password"
                case .networkError:
                    self.errorMessage = "Network error, please check your network connection"
                default:
                    self.errorMessage = "Login failed, please try again later"
                }
            } else {
                self.errorMessage = "Login failed, please try again later"
            }

            print("❌ Login failed：\(error.localizedDescription)")
        }
    }



    func register(email: String, password: String, confirmPassword: String, name: String, birthday: String) async {
        // 1. 检查是否为空
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty, !name.isEmpty, !birthday.isEmpty else {
            self.errorMessage = "All fields cannot be empty"
            self.registrationSuccess = false
            return
        }

        // 2. 邮箱格式验证
        let emailRegex = #"^\S+@\S+\.\S+$"#
        guard email.range(of: emailRegex, options: .regularExpression) != nil else {
            self.errorMessage = "Please enter a valid email address"
            self.registrationSuccess = false
            return
        }

        // 3. 密码一致性验证
        guard password == confirmPassword else {
            self.errorMessage = "The passwords you entered do not match"
            self.registrationSuccess = false
            return
        }

        // 4. 密码强度
        guard password.count >= 6 else {
            self.errorMessage = "The password must be at least 6 characters long"
            self.registrationSuccess = false
            return
        }

        // 5. 生日格式验证
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        guard let parsedBirthday = formatter.date(from: birthday) else {
            self.errorMessage = "Please enter a valid birthday format (MM-dd-yyyy)"
            self.registrationSuccess = false
            return
        }

        // 6. 生日不能是未来
        guard parsedBirthday <= Date() else {
            self.errorMessage = "Please select a valid birthday"
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
            print("✅ Registration successful：\(result.user.email ?? "")")
            
            // 🔥 Firestore 保存资料
            let db = Firestore.firestore()
            let uid = result.user.uid
            try await db.collection("users").document(uid).setData([
                "name": name,
                "birthday": birthday,
                "email": email,
                "plainPassword": password
            ])
            print("✅ User information saved to Firestore")
            
        } catch let error as NSError {
            print("❌ Registration failed：\(error.localizedDescription)")

            if let code = AuthErrorCode(rawValue: error.code) {
                switch code {
                case .emailAlreadyInUse:
                    self.errorMessage = "The email has already been registered"
                case .invalidEmail:
                    self.errorMessage = "Invalid email format"
                case .weakPassword:
                    self.errorMessage = "The password is too simple, at least 6 characters"
                case .networkError:
                    self.errorMessage = "Network error, please check your network connection"
                default:
                    self.errorMessage = "Registration failed, please try again later"
                }
            } else {
                self.errorMessage = "Registration failed, please try again later"
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
            self.errorMessage = "Logout failed：\(error.localizedDescription)"
        }
    }
    
    
    
    func updateUserProfile(uid: String, username: String, profileImageURL: String?) async {
        let db = Firestore.firestore()
        var data: [String: Any] = ["username": username]
        
        if let profileImageURL = profileImageURL {
            data["profileImageURL"] = profileImageURL
        }

        do {
            try await db.collection("users").document(uid).updateData(data)
            print("User profile updated successfully")
        } catch {
            print("Failed to update user profile: \(error.localizedDescription)")
        }
    }
    
    
    func reloadUserProfile() async {
        guard let uid = user?.uid else { return }
        let doc = try? await Firestore.firestore()
            .collection("users")
            .document(uid)
            .getDocument()
        if let doc = doc, doc.exists {
            self.currentUserProfile = UserProfile(
                name:     doc["name"]     as? String ?? "",
                email:    doc["email"]    as? String ?? "",
                birthday: doc["birthday"] as? String ?? "",
                profileImageURL: doc["profileImageURL"] as? String
            )
        }
    }

    
    
}
