//
//  LocationStatus.swift
//  GeoCameraApp
//
//  Created by Claude on 2026/02/14.
//

import Foundation

/// 位置狀態枚舉
enum LocationStatus: Equatable {
    /// 未授權（使用者拒絕位置權限）
    case notAuthorized

    /// 定位中（正在取得 GPS 位置）
    case locating

    /// 已定位（成功取得位置）
    case located

    /// 錯誤狀態（包含錯誤訊息）
    case error(String)

    // MARK: - Computed Properties

    /// 是否已取得有效位置
    var hasValidLocation: Bool {
        return self == .located
    }

    /// 顯示用的狀態訊息
    var displayMessage: String {
        switch self {
        case .notAuthorized:
            return "未授權位置權限"
        case .locating:
            return "正在定位中..."
        case .located:
            return "定位成功"
        case .error(let message):
            return "定位錯誤：\(message)"
        }
    }
}
