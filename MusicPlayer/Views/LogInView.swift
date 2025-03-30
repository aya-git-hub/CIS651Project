//
//  LogInView.swift
//  Login
//
//  Created by Pengfei Liu on 3/27/25.
//

import SwiftUI

struct LogInView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var isLinkActive = false
    @State private var navigateToContentView = false
    
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
                                    value: $viewModel.email
                                )
                                
                                CustomTextField(
                                    placeholder: "Password",
                                    imageName: "lock",
                                    bColor: Color("textColor1"),
                                    tOpacity: 0.6,
                                    value: $viewModel.password
                                )
                            }
                            
                            // 错误提示
                            if viewModel.showError {
                                Text(viewModel.errorMessage)
                                    .foregroundColor(.red)
                                    .padding()
                            }
                            
                            
                            
                            
                            
                            // Forgot Password & Sign In Button
                            VStack(alignment: .trailing) {
                                NavigationLink(destination: ForgetPasswordView(), isActive: $isLinkActive) {
                                    Button(action: {
                                        self.isLinkActive = true
                                    }, label: {
                                        Text("Forgot Password?")
                                            .fontWeight(.medium)
                                    })
                                }
                                
                                Button(action: {
                                    if viewModel.login() {
                                        navigateToContentView = true
                                    }
                                }) {
                                    CustomButton(title: "SIGN UP", bgColor: ("Color1"))
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                                                    
                        }
                        
                        // Sign Up Section
                        HStack {
                            Text("Don't have an account?")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .font(.system(size: 18))
                            
                            NavigationLink(destination: SignUpView(), isActive: $isLinkActive) {
                                Button(action: {self.isLinkActive = true}, label:{                                Text("SIGN UP")
                                        .fontWeight(.bold)
                                        .foregroundColor(Color("Color1"))
                                    .font(.system(size: 18))})
                                
                            }
                            
                            
                            
                        }
                        .frame(height: 63)
                        .frame(maxWidth: .infinity)
                        .background(Color("Color2"))
                        .ignoresSafeArea()
                        
                        // Bottom Bar
                        TopBarView()
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, 10)
                    }
                    .edgesIgnoringSafeArea(.bottom)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    LogInView()
}
