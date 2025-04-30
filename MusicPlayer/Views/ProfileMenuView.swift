//
//  ProfileMenuView.swift
//  MovieListApp
//
//  Created by Pengfei Liu on 4/18/25.
//



import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import PhotosUI

struct ProfileMenuView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showProfileSheet = false

    var body: some View {
        Menu {
            // Profile 选项：打开编辑页面
            Button("Profile") {
                showProfileSheet = true
            }

            // Sign Out
            Button(role: .destructive) {
                authViewModel.signOut()
            } label: {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.forward")
            }

        } label: {
            if let url = authViewModel.currentUserProfile?.profileImageURL,
               let imageURL = URL(string: url) {
                AsyncImage(url: imageURL) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 36, height: 36)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.crop.circle")
                    .font(.title2)
            }
        }
        .sheet(isPresented: $showProfileSheet) {
            UserProfileView()
        }
    }
}
