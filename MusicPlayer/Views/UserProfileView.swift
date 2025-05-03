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
                    // MARK: Profile Image Picker
                    Image("avatar2")
                         .resizable()
                         .scaledToFill()
                         .frame(width: 120, height: 120)
                         .clipShape(Circle())
                         .overlay(Circle().stroke(Color.gray.opacity(0.4), lineWidth: 2))

                    

                    // MARK: User Information Fields
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

                    // MARK: Error Message
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    // MARK: Save Button
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

    // MARK: Load Current User Profile
    private func loadProfile() {
        let profile = authViewModel.currentUserProfile
        self.name      = profile?.name     ?? ""
        self.email     = profile?.email    ?? ""
        self.birthday  = profile?.birthday ?? ""
        self.imageURLString = profile?.profileImageURL
    }

    // MARK: Save Information to Firestore
    private func saveProfile() async {
        guard let uid = authViewModel.user?.uid else { return }
        isSaving = true
        errorMessage = ""

        var data: [String: Any] = [
            "name": name,
            "birthday": birthday
        ]

        // If user selected a new profile image
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

