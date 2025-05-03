//
//  LogInView.swift
//  Login
//
//  Created by Pengfei Liu on 3/27/25.
//

import SwiftUI

struct LogInView: View {
    @StateObject var authViewModel = AuthViewModel.getAuth()
    @ObservedObject var viewModel: PlayerTestViewModel
    @EnvironmentObject var downloadVM: DownloadPlayViewModel // ✅ Inject download ViewModel
    
    // ① Persist last login credentials
    @AppStorage("lastEmail") private var storedEmail: String = ""
    @AppStorage("lastPassword") private var storedPassword: String = ""

    // ② State bound to input fields
    @State private var email: String = ""
    @State private var password: String = ""


    @State private var navigateToContentView = false
    @State private var showForgetPassword = false
    @State private var showSignUp = false
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                // ✅ Page navigation: Go to main interface (test page) after successful login
                NavigationLink(
                    destination: MainView(viewModel: viewModel)
                        .environmentObject(downloadVM), // ✅ Continue passing
                    isActive: $navigateToContentView
                ) {
                    EmptyView()
                }

                VStack {
                    VStack(spacing: 40) {
                        // Background design
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

                        // Input fields area
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

                            // Forgot password + Login button
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
                                            // ③ Save to local storage after successful login
                                            storedEmail = email
                                            storedPassword = password
                                            // ✅ Call sync after successful login
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

                        // Sign up button
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
            .onChange(of: storedEmail) { email = $0 }
            .onChange(of: storedPassword) { password = $0 }
        }
    }
}

