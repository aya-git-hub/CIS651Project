//
//  SignUpView.swift
//  Login
//
//  Created by Pengfei Liu on 3/27/25.
//

import SwiftUI

struct SignUpView: View {
    var authViewModel = AuthViewModel.getAuth()
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var birthday = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var showSuccessAlert = false
    
    @State private var isLoading = false
    
    @AppStorage("lastEmail") private var storedEmail: String = ""
    @AppStorage("lastPassword") private var storedPassword: String = ""

    var body: some View {
        NavigationView {
            ZStack(alignment:.topLeading) {
                Color("Color1").ignoresSafeArea()

                VStack {
                    VStack(spacing: 40) {
                        ZStack {
                            Ellipse()
                                .frame(width: 458, height: 420)
                                .padding(.trailing, -500)
                                .foregroundColor(Color("Color2"))
                                .padding(.top, -200)

                            Text("Create \nAccount")
                                .foregroundColor(.white)
                                .font(.system(size: 35))
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 20)
                                .padding(.top, 100)
                        }

                        VStack(spacing: 20){
                            // 输入框区域
                            CustomTextField(
                                placeholder: "Name",
                                imageName: "person",
                                bColor: Color("textColor2"),
                                tOpacity: 1.0,
                                value: $name)

                            BirthdayInputField(birthdayText: $birthday)

                            CustomTextField(
                                placeholder: "Email",
                                imageName: "envelope",
                                bColor: Color("textColor2"),
                                tOpacity: 1.0,
                                value: $email)

                            CustomTextField(
                                placeholder: "Password",
                                imageName: "lock",
                                bColor: Color("textColor2"),
                                tOpacity: 1.0,
                                value: $password)

                            CustomTextField(
                                placeholder: "Confirm Password",
                                imageName: "lock",
                                bColor: Color("textColor2"),
                                tOpacity: 1.0,
                                value: $confirmPassword)

                            // 错误提示
                            if showError {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .padding(.top, 4)
                            }

                            // 注册按钮
                            VStack(alignment: .trailing) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(1.5)
                                        .padding()
                                } else {
                                    Button {
                                        Task {
                                            isLoading = true
                                            showError = false
                                            errorMessage = ""

                                            if password != confirmPassword {
                                                errorMessage = "Passwords do not match"
                                                showError = true
                                                isLoading = false
                                                return
                                            }

                                            await authViewModel.register(
                                                email: email,
                                                password: password,
                                                confirmPassword: confirmPassword,
                                                name: name,
                                                birthday: birthday
                                            )

                                            isLoading = false

                                            if authViewModel.registrationSuccess {
                                                showError = false
                                                await MainActor.run {
                                                    showSuccessAlert = true
                                                }
                                                storedEmail    = email
                                                storedPassword = password
                                                showSuccessAlert = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                    dismiss()
                                                }
                                            } else {
                                                errorMessage = authViewModel.errorMessage
                                                showError = true
                                            }
                                        }
                                    } label: {
                                        CustomButton(title: "SIGN UP", bgColor: "Color2")
                                    }
                                }


                            }
                            .padding(.horizontal, 20)

                            Spacer()

                            // 已有账号 - 返回按钮
                            HStack {
                                Text("Already have an account?")
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
                    .edgesIgnoringSafeArea(.bottom)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Signup success！", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}
