//
//  LogInView.swift
//  Login
//
//  Created by Pengfei Liu on 3/27/25.
//

import SwiftUI

struct LogInView: View {
    @StateObject var authViewModel = AuthViewModel()
    
    @State private var email = ""
    @State private var password = ""
    @State private var navigateToContentView = false
    
    @State private var showForgetPassword = false
    @State private var showSignUp = false
    
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                NavigationLink(
                    destination: MainView(),
                    isActive: $navigateToContentView
                ) {
                    EmptyView()
                }
                
                
                
                VStack {
                    VStack(spacing: 40) {
                        // Background Design
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
                        
                        // Input Fields
                        VStack(spacing: 30) {
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
                            }
                            
                            // 错误提示
                            if !authViewModel.errorMessage.isEmpty {
                                Text(authViewModel.errorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                            }
                            
                            
                            
                            
                            // Forgot Password & Sign In Button
                            VStack(alignment: .trailing) {
                                NavigationLink(destination: ForgetPasswordView(), isActive: $showForgetPassword) {
                                    Button(action: {
                                        self.showForgetPassword = true
                                    }, label: {
                                        Text("Forgot Password?")
                                            .fontWeight(.medium)
                                    })
                                }
                                
                                Button {
                                    Task {
                                        authViewModel.errorMessage = ""

                                        await authViewModel.login(email: email, password: password)

                                        if authViewModel.isLoggedIn {
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
                        
                        // Sign Up Section
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
                        
                        // Bottom Bar
                        TopBarView()
                            //.frame(maxWidth: .infinity)
                            .padding(.bottom, 10)
                    }
                    .edgesIgnoringSafeArea(.bottom)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

