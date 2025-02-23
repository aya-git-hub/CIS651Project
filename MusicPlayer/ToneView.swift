import SwiftUI
import AVFoundation

struct ToneView: View {
    @State private var audioPlayer: AVAudioPlayer?
    let toneProcessor = ToneProcessor();
    
    /// 根据传入的 note 名称和颜色生成一个按钮
    func noteButton(note: String, color: Color) -> some View {
        Button(action: {
            toneProcessor.playSound(note: note)
                print(ToneProcessor.numToTone[Int(note)!]!)
            }) {
            // 空文本充当按钮占位，充满整个区域
            Text("")
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .background(color)
        }
    }
    
    var body: some View {
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
        .navigationBarHidden(true)

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ToneView()
    }
}
