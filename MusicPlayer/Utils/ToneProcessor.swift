//
//  ToneProcessor.swift
//  Xylophone
//
//  Created by yuao ai on 2/23/25.
//  Copyright © 2025 London App Brewery. All rights reserved.
//
import AVFoundation
import Foundation
import SwiftUI
class ToneProcessor {
    /// Returns the solfege note corresponding to the given number (1 to 7).
    /// - Parameter number: An integer between 1 and 7.
    /// - Returns: A string representing the note ("do", "re", "mi", "fa", "so", "la", "ti"), or nil if the number is out of range.
    static var numToTone = Dictionary<Int,String>(dictionaryLiteral:
        (1, "do"),
        (2, "re"),
        (3, "mi"),
        (4, "fa"),
        (5, "so"),
        (6, "la"),
        (7, "ti")
    )
    var audioPlayer: AVAudioPlayer?
    var DB:DatabaseManager = DatabaseManager()
    
    // 依次播放录制的音阶（简单延时播放）
    
    func playSound(note: String) {
        if let url = Bundle.main.url(forResource: "note\(note)", withExtension: "wav") {
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            } catch {
                print("Error playing sound for \(note): \(error.localizedDescription)")
            }
        }
    }
    
    /// Returns the solfege note corresponding to the given number (1 to 7).
    /// - Parameter number: An integer between 1 and 7.
    /// - Returns: The corresponding note as a String, or nil if the number is out of range.
    func noteFor(number: Int) -> String? {
        switch number {
        case 1: return "do"
        case 2: return "re"
        case 3: return "mi"
        case 4: return "fa"
        case 5: return "so"
        case 6: return "la"
        case 7: return "ti"
        default: return nil
        }
    }
}
