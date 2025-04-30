//
//  UserProfileView.swift
//  MovieListApp
//
//  Created by Pengfei Liu on 4/18/25.
//


import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import PhotosUI
import UIKit

struct UserProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var selectedImage: PhotosPickerItem?
    @State private var profileImage: UIImage?
    @State private var imageURLString: String?

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var birthday: String = ""

    @State private var isSaving = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: 头像选择器
                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        Group {
                            if let uiImage = profileImage {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                            } else if let urlString = imageURLString,
                                      let url = URL(string: urlString) {
                                AsyncImage(url: url) { img in
                                    img.resizable()
                                } placeholder: {
                                    Color.gray
                                }
                                .scaledToFill()
                            } else {
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.4), lineWidth: 2))
                    }

                    // MARK: 用户信息字段
                    Group {
                        TextField("Name", text: $name)
                            .autocapitalization(.words)
                        TextField("Email", text: $email)
                            .disabled(true)
                            .foregroundColor(.gray)
                        TextField("Birthday (MM-dd-yyyy)", text: $birthday)
                            .keyboardType(.numbersAndPunctuation)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                    // MARK: 错误信息
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    // MARK: 保存按钮
                    Button {
                        Task { await saveProfile() }
                    } label: {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Save")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                }
            }
            .onAppear {
                Task { await authViewModel.reloadUserProfile() }
                loadProfile()
            }
            .onChange(of: selectedImage) { _ in
                Task {
                    if let data = try? await selectedImage?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data!) {
                        self.profileImage = uiImage
                    }
                }
            }
        }
    }

    // MARK: 加载当前用户信息
    private func loadProfile() {
        let profile = authViewModel.currentUserProfile
        self.name      = profile?.name     ?? ""
        self.email     = profile?.email    ?? ""
        self.birthday  = profile?.birthday ?? ""
        self.imageURLString = profile?.profileImageURL
    }

    // MARK: 保存信息到 Firestore
    private func saveProfile() async {
        guard let uid = authViewModel.user?.uid else { return }
        isSaving = true
        errorMessage = ""

        var data: [String: Any] = [
            "name": name,
            "birthday": birthday
        ]

        // 如果用户选了新头像
        if let uiImage = profileImage {
            do {
                let url = try await uploadImage(uiImage, for: uid)
                data["profileImageURL"] = url.absoluteString
            } catch {
                errorMessage = "Image upload failed: \(error.localizedDescription)"
                isSaving = false
                return
            }
        }

        do {
            try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .updateData(data)
            await authViewModel.reloadUserProfile()
            dismiss()
        } catch {
            errorMessage = "Save failed: \(error.localizedDescription)"
        }

        isSaving = false
    }



    func uploadImage(_ image: UIImage, for uid: String) async throws -> URL {
        // 全局函数调用，前面不要加 image.
        guard let imageData = UIImageJPEGRepresentation(image, 0.8) else {
            throw URLError(.cannotCreateFile)
        }
        let ref = Storage.storage().reference().child("profileImages/\(uid).jpg")
        let _ = try await ref.putDataAsync(imageData, metadata: nil)
        return try await ref.downloadURL()
    }

    struct UserProfileView_Previews: PreviewProvider {
        static var previews: some View {
            UserProfileView()
                .environmentObject(AuthViewModel.getAuth())
        }
    }
}
