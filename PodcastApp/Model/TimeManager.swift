//
//  TimeManager.swift
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

import CoreMedia

struct TimeManager {
    
    /// Transfer seconds(Float) to 00:00:00(String).
    /// - Parameter seconds: The time will be transfered to timecode String.
    /// - Returns: Timecode String. Would be like 00:00:00.
    static func floatToTimecodeString(seconds: Float) -> String {
        guard !(seconds.isNaN || seconds.isInfinite) else {
            return "00:00"
        }
        let time = Int(floor(seconds))

        let hours = time / 3600
        let minutes = time / 60 - hours * 60
        let seconds = time % 60
        let timecodeString = hours == .zero ? String(format: "%02ld:%02ld", minutes, seconds) : String(format: "%02ld:%02ld:%02ld", hours, minutes, seconds)
        return timecodeString
    }
    
}



