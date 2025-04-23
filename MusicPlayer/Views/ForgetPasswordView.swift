//
//  ForgetPasswordView.swift
//  Login
//
//  Created by Pengfei Liu on 4/19/25.
//

import SwiftUI
import Firebase

import SwiftUI
import Firebase

struct ForgetPasswordView: View {
    @Environment(\.dismiss) var dismiss

    @State private var email = ""
    @State private var birthday = ""
    @State private var recoveredPassword: String?
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showError = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                Color("Color1").ignoresSafeArea()

                VStack {
                    VStack(spacing: 40) {
                        // 顶部背景与标题
                        ZStack {
                            Ellipse()
                                .frame(width: 458, height: 420)
                                .padding(.trailing, -500)
                                .foregroundColor(Color("Color2"))
                                .padding(.top, -200)

                            Text("Find \nPassword")
                                .foregroundColor(.white)
                                .font(.system(size: 35))
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 20)
                                .padding(.top, 100)
                        }

                        // 输入框区域
                        VStack(spacing: 20) {
                            CustomTextField(
                                placeholder: "Email",
                                imageName: "envelope",
                                bColor: Color("textColor2"),
                                tOpacity: 1.0,
                                value: $email)

                            BirthdayInputField(birthdayText: $birthday)

                            // 错误提示
                            if showError {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .padding(.top, 4)
                            }

                            // 结果展示
                            if let password = recoveredPassword {
                                Text("✅ 你的密码是：\(password)")
                                    .foregroundColor(.green)
                                    .fontWeight(.bold)
                                    .padding(.top, 4)
                            }

                            // 找回按钮
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.5)
                                    .padding()
                            } else {
                                Button {
                                    Task {
                                        await handleRecover()
                                    }
                                } label: {
                                    CustomButton(title: "FIND PASSWORD", bgColor: "Color2")
                                }
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 20)

                        // 返回登录按钮
                        HStack {
                            Text("Remember your password?")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .font(.system(size: 18))

                            Button("SIGN IN") {
                                dismiss()
                            }
                            .font(.system(size: 18))
                            .fontWeight(.bold)
                            .foregroundColor(Color("Color1"))
                        }
                        .frame(height: 63)
                        .frame(maxWidth: .infinity)
                        .background(Color("Color2"))
                        .ignoresSafeArea()
                    }

                    TopBarView()
                        .padding(.bottom, -500)
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: 找回逻辑
    func handleRecover() async {
        errorMessage = ""
        recoveredPassword = nil
        showError = false
        isLoading = true

        guard !email.isEmpty, !birthday.isEmpty else {
            errorMessage = "请输入邮箱和生日"
            showError = true
            isLoading = false
            return
        }

        do {
            let snapshot = try await Firestore.firestore()
                .collection("users")
                .whereField("email", isEqualTo: email)
                .whereField("birthday", isEqualTo: birthday)
                .getDocuments()

            if let doc = snapshot.documents.first {
                if let password = doc.data()["plainPassword"] as? String {
                    recoveredPassword = password
                } else {
                    errorMessage = "没有找到密码字段"
                    showError = true
                }
            } else {
                errorMessage = "没有找到匹配的用户"
                showError = true
            }
        } catch {
            errorMessage = "出错：\(error.localizedDescription)"
            showError = true
        }

        isLoading = false
    }
}

