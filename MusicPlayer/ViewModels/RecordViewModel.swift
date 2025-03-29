//
//  RecordModelView.swift
//  Xylophone
//
//  Created by yuao ai on 2/23/25.
//  Copyright © 2025 London App Brewery. All rights reserved.
//
import SwiftUI
import Foundation
import AVFoundation

class RecordViewModel: ObservableObject{
    @Published var recordedNotes = Array<String>();
    @Published  var audioPlayer: AVAudioPlayer?
    
    let toneProcessor = ToneProcessor()
    
    func playRecording() {
        
        let notes = recordedNotes
        for (index, note) in notes.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                self.toneProcessor.playSound(note: note)
            }
        }
    }
}

