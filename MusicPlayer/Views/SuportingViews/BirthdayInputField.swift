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

    // 估算一下你的弹窗高度
    private let pickerHeight: CGFloat = 360

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.white)
                    .padding(.leading, 20)

                ZStack(alignment: .leading) {
                    if birthdayText.isEmpty {
                        Text("Birthday (MM-dd-yyyy)")
                            .foregroundColor(.white.opacity(1))
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
                    withAnimation { showPicker.toggle() }
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
        // ▶️ 关键：当弹出时，把视图底部向下撑开一段距离
        .padding(.bottom, showPicker ? pickerHeight : 0)
        // ▶️ 关键：声明整个区域都可点（包含下方那块透明 padding 区域）
        .contentShape(Rectangle())
        .overlay(
            Group {
                if showPicker {
                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            Button("Done") {
                                let fmt = DateFormatter()
                                fmt.dateFormat = "MM-dd-yyyy"
                                birthdayText = fmt.string(from: selectedDate)
                                showPicker = false
                            }
                            .padding(.top, 8)
                            .padding(.trailing, 12)
                        }

                        DatePicker(
                            "",
                            selection: $selectedDate,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .padding(.bottom, 12)
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 8)
                    .padding(.horizontal, 16)
                    .offset(y: 8)
                    .zIndex(1)
                }
            },
            alignment: .bottom
        )
        .animation(.easeInOut(duration: 0.25), value: showPicker)
    }
}
