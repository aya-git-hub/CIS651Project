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
                        // Top background and title
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

                        // Input fields area
                        VStack(spacing: 20) {
                            CustomTextField(
                                placeholder: "Email",
                                imageName: "envelope",
                                bColor: Color("textColor2"),
                                tOpacity: 1.0,
                                value: $email)

                            BirthdayInputField(birthdayText: $birthday)

                            // Error message
                            if showError {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .padding(.top, 4)
                            }

                            // Result display
                            if let password = recoveredPassword {
                                Text("✅ Your password is: \(password)")
                                    .foregroundColor(.green)
                                    .fontWeight(.bold)
                                    .padding(.top, 4)
                            }

                            // Recover button
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

                        // Return to login button
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

    // MARK: Recovery logic
    func handleRecover() async {
        errorMessage = ""
        recoveredPassword = nil
        showError = false
        isLoading = true

        guard !email.isEmpty, !birthday.isEmpty else {
            errorMessage = "Please enter email and birthday"
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
                    errorMessage = "Password field not found"
                    showError = true
                }
            } else {
                errorMessage = "No matching user found"
                showError = true
            }
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
            showError = true
        }

        isLoading = false
    }
}

