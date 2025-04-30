//
//  apikey.swift
//  MusicPlayer
//
//  Created by yuao ai on 4/22/25.
//  Copyright © 2025 London App Brewery. All rights reserved.
//

import Foundation
enum Configuration {
    static var deepseekApiKey: String {
        guard let apiKey = ProcessInfo.processInfo.environment["DEEPSEEK_API_KEY"] else {
            fatalError("Cannot find DEEPSEEK_API_KEY value in environment variables. Please set it in the scheme editor.")
        }
        return apiKey
    }
    static var freeApiKey: String {
        guard let apiKey = ProcessInfo.processInfo.environment["FREE_API_KEY"] else {
            fatalError("Cannot find FREE_API_KEY value in environment variables. Please set it in the scheme editor.")
        }
        return apiKey
    }
    
}
