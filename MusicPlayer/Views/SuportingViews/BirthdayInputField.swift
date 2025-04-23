//
//  BirthdayInputField.swift
//  MusicPlayer
//
//  Created by Pengfei Liu on 4/20/25.
//

import SwiftUI

struct BirthdayInputField: View {
    @Binding var birthdayText: String
    @State private var selectedDate = Date()
    @State private var showPicker = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.white)
                    .padding(.leading, 20)

                ZStack(alignment: .leading) {
                    if birthdayText.isEmpty {
                        Text("Birthday (MM-dd-yyyy)")
                            .foregroundColor(.white.opacity(1)) // ✅ 白色带透明度
                            .font(.system(size: 20))
                            .padding(.leading, 10)
                    }

                    TextField("", text: $birthdayText)
                        .foregroundColor(.white)
                        .keyboardType(.numbersAndPunctuation)
                        .font(.system(size: 20))
                        .padding(.vertical, 10)
                        .padding(.leading, 10)
                }

                Button {
                    showPicker.toggle()
                } label: {
                    Image(systemName: "chevron.down.circle")
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.trailing, 20)
            }

            Divider()
                .background(Color.white.opacity(0.6))
                .padding(.horizontal, 20)
        }
        .overlay(
            Group {
                if showPicker {
                    VStack(alignment: .trailing, spacing: 0) {
                        HStack {
                            Spacer()
                            Button("Done") {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "MM-dd-yyyy"
                                birthdayText = formatter.string(from: selectedDate)
                                showPicker = false
                            }
                            .padding()
                            .foregroundColor(.blue)
                        }

                        DatePicker(
                            "",
                            selection: $selectedDate,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .padding()
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 8)
                    .padding(.horizontal)
                    .zIndex(1)
                }
            },
            alignment: .bottom
        )

        .animation(.easeInOut(duration: 0.25), value: showPicker)
    }
}
