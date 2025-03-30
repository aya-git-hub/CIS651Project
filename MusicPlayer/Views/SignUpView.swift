//
//  SignUpView.swift
//  Login
//
//  Created by Pengfei Liu on 3/27/25.
//

import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @State private var isLinkActive = false
    
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
                            VStack(spacing: 20){
                                CustomTextField(
                                    placeholder: "Name",
                                    imageName: "person",
                                    bColor: Color("textColor2"),
                                    tOpacity: 1.0,
                                    value: $viewModel.name)
                                
                                
                                CustomTextField(
                                    placeholder: "Birthday(MM-dd-yyyy)",
                                    imageName: "calendar",
                                    bColor: Color("textColor2"),
                                    tOpacity: 1.0,
                                    value: $viewModel.birthday1)
                                
                                CustomTextField(
                                    placeholder: "Email",
                                    imageName: "envelope",
                                    bColor: Color("textColor2"),
                                    tOpacity: 1.0,
                                    value: $viewModel.email)
                                
                                CustomTextField(
                                    placeholder: "Password",
                                    imageName: "lock",
                                    bColor: Color("textColor2"),
                                    tOpacity: 1.0,
                                    value: $viewModel.password)
                                
                                CustomTextField(
                                    placeholder: "Confirm Password",
                                    imageName: "lock",
                                    bColor: Color("textColor2"),
                                    tOpacity: 1.0,
                                    value: $viewModel.confirmPassword)
                            }
                            
                            // 错误提示
                            if viewModel.showError {
                                Text(viewModel.errorMessage)
                                    .foregroundColor(.red)
                                    .padding()
                            }
                            
                            
                            
                            VStack(alignment: .trailing) {

                                Button(action: {                             if viewModel.signUp() {
           
                                        self.isLinkActive = true
                                }}) {
                                    CustomButton(title: "SIGN UP", bgColor:("Color2"))
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            Spacer()
                            
                            HStack{
                                Text("Already have an account?")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .font(.system(size: 18))
                                
                                NavigationLink(destination: LogInView(), isActive: $isLinkActive) {
                                    Button(action: {self.isLinkActive = true}, label:{                                Text("SIGN IN")
                                            .fontWeight(.bold)
                                            .foregroundColor(Color("Color1"))
                                            .font(.system(size: 18))})
                                    
                                }
                                

                                

 
                            }
                            .frame(height: 63)
                            .frame(minWidth:0, maxWidth: .infinity)
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
            
    }
}

#Preview {
    SignUpView()
}
