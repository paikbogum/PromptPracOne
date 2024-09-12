//
//  RecordingManager.swift
//  PromptPracOne
//
//  Created by 백현진 on 8/22/24.
//

import Foundation
import AVFoundation

class RecordingManager: NSObject {
    var scriptText: String = ""
    var scriptLines: [String] = []
    var currentDisplayStartIndex: Int = 0
    
    var recordingStartTime: Date?
    var recordingTimer: Timer?
    var scriptTimer: Timer?
    var videoOutput: AVCaptureMovieFileOutput?
    
    
    func startRecording(with outputURL: URL, delegate: AVCaptureFileOutputRecordingDelegate) {
        videoOutput?.startRecording(to: outputURL, recordingDelegate: delegate)
        recordingStartTime = Date()
    }
    
    func stopRecording() {
        videoOutput?.stopRecording()
        recordingTimer?.invalidate()
        scriptTimer?.invalidate()
    }
    
    func resetScriptIndex() {
        currentDisplayStartIndex = 0
    }
    
    func updateScriptIndex() -> Bool {
        if currentDisplayStartIndex < scriptLines.count - 1 {
            currentDisplayStartIndex += 1
            return true
        } else {
            scriptTimer?.invalidate()
            return false
        }
    }
    
    func getVisibleScriptLines() -> String {
        let endIndex = min(currentDisplayStartIndex + 5, scriptLines.count)
        let visibleLines = scriptLines[currentDisplayStartIndex..<endIndex]
        return visibleLines.joined(separator: "\n")
    }
    
    func getRecordingElapsedTime() -> String {
        guard let startTime = recordingStartTime else { return "00:00" }
        let currentTime = Date()
        let elapsedTime = currentTime.timeIntervalSince(startTime)
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

