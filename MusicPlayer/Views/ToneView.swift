import SwiftUI
import AVFoundation

struct ToneView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var audioPlayer: AVAudioPlayer?
    let toneProcessor = ToneProcessor()
    
    /// 根据传入的 note 名称和颜色生成一个按钮
    func noteButton(note: String, color: Color) -> some View {
        Button(action: {
            toneProcessor.playSound(note: note)
            if let intNote = Int(note), let tone = ToneProcessor.numToTone[intNote] {
                print(tone)
                
            }
        }) {
            Text("")
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .background(color)
        }
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                noteButton(note: "1", color: .red)
                noteButton(note: "2", color: .orange)
                noteButton(note: "3", color: .yellow)
                noteButton(note: "4", color: .green)
                noteButton(note: "5", color: .blue)
                noteButton(note: "6", color: .indigo)
                noteButton(note: "7", color: .purple)
            }
            .edgesIgnoringSafeArea(.all)
            
            // 自定义 Back 按钮，位于左上角
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Back")
                    .padding(10)
                    .background(Color.gray.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding([.top, .leading], 20)
        }
        .navigationBarHidden(true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ToneView()
        }
    }
}
