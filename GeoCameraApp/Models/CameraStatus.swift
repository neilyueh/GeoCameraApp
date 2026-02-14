//
//  CameraStatus.swift
//  GeoCameraApp
//
//  Created by Claude on 2026/02/14.
//

import Foundation

/// 相機狀態枚舉
enum CameraStatus: Equatable {
    /// 未授權（使用者拒絕相機權限）
    case notAuthorized

    /// 設定中（正在初始化相機）
    case configuring

    /// 準備就緒（可以拍照）
    case ready

    /// 拍照中（正在捕捉照片）
    case capturing

    /// 錯誤狀態（包含錯誤訊息）
    case error(String)

    // MARK: - Computed Properties

    /// 是否可以拍照
    var canCapture: Bool {
        return self == .ready
    }

    /// 顯示用的狀態訊息
    var displayMessage: String {
        switch self {
        case .notAuthorized:
            return "未授權相機權限"
        case .configuring:
            return "正在啟動相機..."
        case .ready:
            return "準備就緒"
        case .capturing:
            return "拍照中..."
        case .error(let message):
            return "錯誤：\(message)"
        }
    }
}
