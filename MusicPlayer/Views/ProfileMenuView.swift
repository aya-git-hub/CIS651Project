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
            // Profile
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
            Image("avatar2")
                .resizable()
                .scaledToFill()
                .frame(width: 36, height: 36)
                .clipShape(Circle())
        }
        .sheet(isPresented: $showProfileSheet) {
            UserProfileView()
        }
    }
}
