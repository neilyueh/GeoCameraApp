//
//  AudioService.swift
//  GeoCameraApp
//
//  Created by Claude on 2026/02/14.
//

import AudioToolbox
import Foundation

/// 聲音服務協議
protocol AudioServiceProtocol {
    /// 播放快門聲音
    func playShutterSound()
    /// 播放成功提示音
    func playSuccessSound()
    /// 播放錯誤提示音
    func playErrorSound()
    /// 播放輕觸震動
    func playHapticFeedback()
}

/// 聲音服務實作
class AudioService: AudioServiceProtocol {
    // MARK: - Public Methods

    /// 播放系統快門聲音
    /// - Note: 使用 SystemSoundID 1108，此聲音無法被靜音開關關閉
    func playShutterSound() {
        AudioServicesPlaySystemSound(Constants.Audio.shutterSoundID)
    }
}

// MARK: - Additional Sound Effects (Optional)

extension AudioService {
    /// 播放成功提示音
    func playSuccessSound() {
        AudioServicesPlaySystemSound(SystemSoundID(1057)) // Tock
    }

    /// 播放錯誤提示音
    func playErrorSound() {
        AudioServicesPlaySystemSound(SystemSoundID(1053)) // Error
    }

    /// 播放輕觸震動
    func playHapticFeedback() {
        AudioServicesPlaySystemSound(SystemSoundID(1519)) // Peek
    }
}
