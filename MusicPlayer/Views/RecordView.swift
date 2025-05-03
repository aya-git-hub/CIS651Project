import SwiftUI
import AVFoundation



struct RecordView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var audioPlayer: AVAudioPlayer?
    //@State private var recordedNotes: [String] = []
    @State private var isRecording = false
    let toneProcessor = ToneProcessor();
    var authViewModel = AuthViewModel.getAuth();
    
    @StateObject var recordModel = RecordViewModel()

    
    // Button: Play corresponding scale when clicked, and save scale to array when in recording state
    func noteButton(note: String, color: Color) -> some View {
        Button(action: {
            toneProcessor.playSound(note: note)
            if self.isRecording {
                recordModel.recordedNotes.append(note)
            }
        }) {
            Text("")
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .background(color)
        }
    }
    
    var body: some View {
            VStack(spacing: 0) {
                // Upper part: Seven scale buttons
                noteButton(note: "1", color: .red)
                noteButton(note: "2", color: .orange)
                noteButton(note: "3", color: .yellow)
                noteButton(note: "4", color: .green)
                noteButton(note: "5", color: .blue)
                noteButton(note: "6", color: .indigo)
                noteButton(note: "7", color: .purple)
                
                // Lower part: Three control buttons
                HStack(spacing: 20) {
                    Button(action: {
                        
                        // Toggle recording state, clear previous records when starting recording
                        self.isRecording.toggle()
                        if self.isRecording {
                            recordModel.recordedNotes.removeAll()
                        } else {
                            print("Recorded sequence: \(recordModel.recordedNotes)")
                        }
                    }) {
                        Text(isRecording ? "Stop Recording" : "Record")
                            .padding()
                            .background(isRecording ? Color.red : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        recordModel.playRecording()
                    }) {
                        Text("Play")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Back")
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            .edgesIgnoringSafeArea(.all)
            .navigationTitle("Record Tones")
            
        }
    }
struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RecordView()
        }
    }
}
