//
//  LogInView.swift
//  Login
//
//  Created by Pengfei Liu on 3/27/25.
//

import SwiftUI

struct LogInView: View {
    @StateObject var authViewModel = AuthViewModel.getAuth()
    @EnvironmentObject var downloadVM: DownloadPlayViewModel // ✅ 注入下载 ViewModel
    
    // ① 持久化上次登录的账号密码
    @AppStorage("lastEmail") private var storedEmail: String = ""
    @AppStorage("lastPassword") private var storedPassword: String = ""

    // ② 绑定到输入框的 State
    @State private var email: String = ""
    @State private var password: String = ""


    @State private var navigateToContentView = false
    @State private var showForgetPassword = false
    @State private var showSignUp = false
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                // ✅ 页面跳转：成功登录后前往主界面（测试页面）
                NavigationLink(
                    destination: MainView(viewModel: PlayerTestViewModel())
                        .environmentObject(downloadVM), // ✅ 继续传入
                    isActive: $navigateToContentView
                ) {
                    EmptyView()
                }

                VStack {
                    VStack(spacing: 40) {
                        // 背景设计
                        ZStack {
                            Ellipse()
                                .frame(width: 510, height: 478)
                                .padding(.leading, -200)
                                .foregroundColor(Color("Color2"))
                                .padding(.top, -200)

                            Ellipse()
                                .frame(width: 458, height: 420)
                                .padding(.trailing, -500)
                                .foregroundColor(Color("Color1"))
                                .padding(.top, -200)

                            Text("Welcome \nBack")
                                .foregroundColor(.white)
                                .font(.system(size: 35))
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 20)
                        }

                        // 输入框区域
                        VStack(spacing: 30) {
                            CustomTextField(
                                placeholder: "Email",
                                imageName: "envelope",
                                bColor: Color("textColor1"),
                                tOpacity: 0.6,
                                value: $email
                            )

                            CustomTextField(
                                placeholder: "Password",
                                imageName: "lock",
                                bColor: Color("textColor1"),
                                tOpacity: 0.6,
                                value: $password
                            )

                            if !authViewModel.errorMessage.isEmpty {
                                Text(authViewModel.errorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                            }

                            // 忘记密码 + 登录按钮
                            VStack(alignment: .trailing) {
                                NavigationLink(destination: ForgetPasswordView(), isActive: $showForgetPassword) {
                                    Button("Forgot Password?") {
                                        self.showForgetPassword = true
                                    }
                                }

                                Button {
                                    Task {
                                        authViewModel.errorMessage = ""
                                        await authViewModel.login(email: email, password: password)

                                        if authViewModel.isLoggedIn {
                                            // ③ 登录成功后保存到本地
                                            storedEmail = email
                                            storedPassword = password
                                            // ✅ 登录成功后调用同步
                                            SyncManager.shared.syncDownloadedMusicIfNeeded(viewModel: downloadVM)
                                            navigateToContentView = true
                                        }
                                    }
                                } label: {
                                    CustomButton(title: "SIGN IN", bgColor: "Color1")
                                }

                                Spacer()
                            }
                            .padding(.horizontal, 20)
                        }

                        Spacer()

                        // 注册按钮
                        HStack {
                            Text("Don't have an account?")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .font(.system(size: 18))

                            Button("SIGN UP") {
                                showSignUp = true
                            }
                            .font(.system(size: 18))
                            .fontWeight(.bold)
                            .foregroundColor(Color("Color1"))
                            .fullScreenCover(isPresented: $showSignUp) {
                                SignUpView()
                            }
                        }
                        .frame(height: 63)
                        .frame(maxWidth: .infinity)
                        .background(Color("Color2"))
                        .ignoresSafeArea(edges: .bottom)

                        TopBarView().padding(.bottom, 10)
                    }
                    .edgesIgnoringSafeArea(.bottom)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                if !storedEmail.isEmpty {
                    email = storedEmail
                    password = storedPassword
                }
            }
        }
    }
}
