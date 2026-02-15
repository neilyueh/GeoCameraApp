//
//  LocationInfo.swift
//  GeoCameraApp
//
//  Created by Claude on 2026/02/14.
//

import Foundation

/// 地理位置資訊模型
/// 包含經緯度、地址、時間戳記和準確度
struct LocationInfo {
    /// 緯度（小數點後 6 位）
    let latitude: Double

    /// 經度（小數點後 6 位）
    let longitude: Double

    /// 地址（縣市 + 區域 + 街道名稱）
    /// 如果地理編碼失敗，此值為 nil
    let address: String?

    /// 時間戳記（拍照當下的時間，格式：YYYY/MM/DD HH:MM:SS）
    let timestamp: Date

    /// GPS 準確度（公尺）
    let accuracy: Double

    // MARK: - Computed Properties

    /// 格式化的經緯度字串
    /// 格式：25.033964, 121.564472（小數點後 6 位）
    var formattedLatLong: String {
        return String(format: "%.6f, %.6f", latitude, longitude)
    }

    /// 格式化的日期字串
    /// 格式：YYYY/MM/DD（例如：2026/02/14）
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        formatter.locale = Locale(identifier: "zh_TW")
        return formatter.string(from: timestamp)
    }

    /// 格式化的時間字串
    /// 格式：HH:mm:ss（24小時制，例如：14:30:25）
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.locale = Locale(identifier: "zh_TW")
        return formatter.string(from: timestamp)
    }

    /// 顯示用的地址字串
    /// 如果 address 為 nil，返回預設文字
    var displayAddress: String {
        return address ?? "正在取得地址..."
    }
}

// MARK: - Equatable

extension LocationInfo: Equatable {
    static func == (lhs: LocationInfo, rhs: LocationInfo) -> Bool {
        return lhs.latitude == rhs.latitude &&
               lhs.longitude == rhs.longitude &&
               lhs.address == rhs.address &&
               lhs.timestamp == rhs.timestamp
    }
}

// MARK: - Sample Data (用於預覽和測試)

extension LocationInfo {
    /// 未知位置（當 GPS 無法取得位置時使用）
    static let unknown = LocationInfo(
        latitude: 0.0,
        longitude: 0.0,
        address: "位置資訊無法取得",
        timestamp: Date(),
        accuracy: -1.0
    )
}

#if DEBUG
extension LocationInfo {
    /// 台北 101 測試資料
    static let taipei101 = LocationInfo(
        latitude: 25.033964,
        longitude: 121.564472,
        address: "台北市信義區信義路五段7號",
        timestamp: Date(),
        accuracy: 5.0
    )

    /// 高雄 85 大樓測試資料
    static let kaohsiung85 = LocationInfo(
        latitude: 22.612551,
        longitude: 120.301435,
        address: "高雄市苓雅區自強三路5號",
        timestamp: Date(),
        accuracy: 5.0
    )

    /// 無地址資料（僅座標）
    static let noAddress = LocationInfo(
        latitude: 25.033964,
        longitude: 121.564472,
        address: nil,
        timestamp: Date(),
        accuracy: 10.0
    )
}
#endif
