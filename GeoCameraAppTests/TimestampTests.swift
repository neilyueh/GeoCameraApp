//
//  TimestampTests.swift
//  GeoCameraAppTests
//
//  Created by Claude on 2026/02/15.
//

import Testing
import Foundation
@testable import GeoCameraApp

/// 測試時間戳記功能的正確性
@Suite("時間戳記功能測試")
struct TimestampTests {
    
    @Test("日期格式化測試")
    func testDateFormatting() async throws {
        // 建立特定日期：2026年2月15日 14:30:05
        var components = DateComponents()
        components.year = 2026
        components.month = 2
        components.day = 15
        components.hour = 14
        components.minute = 30
        components.second = 5
        components.timeZone = TimeZone.current
        
        let calendar = Calendar.current
        let testDate = try #require(calendar.date(from: components))
        
        // 建立 LocationInfo
        let locationInfo = LocationInfo(
            latitude: 25.033964,
            longitude: 121.564472,
            address: "測試地址",
            timestamp: testDate,
            accuracy: 5.0
        )
        
        // 驗證日期格式：YYYY/MM/DD
        #expect(locationInfo.formattedDate == "2026/02/15")
    }
    
    @Test("時間格式化測試")
    func testTimeFormatting() async throws {
        // 建立特定時間：2026年2月15日 14:30:05
        var components = DateComponents()
        components.year = 2026
        components.month = 2
        components.day = 15
        components.hour = 14
        components.minute = 30
        components.second = 5
        components.timeZone = TimeZone.current
        
        let calendar = Calendar.current
        let testDate = try #require(calendar.date(from: components))
        
        // 建立 LocationInfo
        let locationInfo = LocationInfo(
            latitude: 25.033964,
            longitude: 121.564472,
            address: "測試地址",
            timestamp: testDate,
            accuracy: 5.0
        )
        
        // 驗證時間格式：HH:MM:SS（24小時制）
        #expect(locationInfo.formattedTime == "14:30:05")
    }
    
    @Test("完整日期時間格式化測試")
    func testFullDateTimeFormatting() async throws {
        // 建立特定日期時間：2026年2月15日 09:05:03
        var components = DateComponents()
        components.year = 2026
        components.month = 2
        components.day = 15
        components.hour = 9
        components.minute = 5
        components.second = 3
        components.timeZone = TimeZone.current
        
        let calendar = Calendar.current
        let testDate = try #require(calendar.date(from: components))
        
        // 驗證完整格式：YYYY/MM/DD HH:MM:SS
        let formatted = testDate.formattedDateTime()
        #expect(formatted == "2026/02/15 09:05:03")
    }
    
    @Test("拍照時間戳記獨立性測試")
    func testCaptureTimestampIndependence() async throws {
        // 模擬場景：GPS 在 5 分鐘前更新，現在才拍照
        
        // 建立 5 分鐘前的 GPS 時間
        let gpsTimestamp = Date().addingTimeInterval(-300)  // 5 分鐘前
        
        let oldLocationInfo = LocationInfo(
            latitude: 25.033964,
            longitude: 121.564472,
            address: "台北市信義區",
            timestamp: gpsTimestamp,
            accuracy: 5.0
        )
        
        // 模擬拍照當下取得新的時間戳記
        let captureTimestamp = Date()
        
        let newLocationInfo = LocationInfo(
            latitude: oldLocationInfo.latitude,
            longitude: oldLocationInfo.longitude,
            address: oldLocationInfo.address,
            timestamp: captureTimestamp,  // 使用拍照當下的時間
            accuracy: oldLocationInfo.accuracy
        )
        
        // 驗證：新的時間戳記應該比舊的晚至少 290 秒（允許 10 秒誤差）
        let timeDifference = newLocationInfo.timestamp.timeIntervalSince(oldLocationInfo.timestamp)
        #expect(timeDifference >= 290)
        #expect(timeDifference <= 310)
        
        // 驗證：經緯度和地址保持不變
        #expect(newLocationInfo.latitude == oldLocationInfo.latitude)
        #expect(newLocationInfo.longitude == oldLocationInfo.longitude)
        #expect(newLocationInfo.address == oldLocationInfo.address)
    }
    
    @Test("無 GPS 情況下的時間戳記測試")
    func testTimestampWithoutGPS() async throws {
        // 模擬沒有 GPS 的情況
        let captureTimestamp = Date()
        
        let locationInfo = LocationInfo(
            latitude: 0.0,
            longitude: 0.0,
            address: "位置資訊無法取得",
            timestamp: captureTimestamp,
            accuracy: -1.0
        )
        
        // 驗證：即使沒有 GPS，時間格式仍然正確
        let dateFormat = locationInfo.formattedDate
        let timeFormat = locationInfo.formattedTime
        
        // 檢查日期格式：YYYY/MM/DD（10 個字元，包含兩個斜線）
        #expect(dateFormat.count == 10)
        #expect(dateFormat.filter { $0 == "/" }.count == 2)
        
        // 檢查時間格式：HH:MM:SS（8 個字元，包含兩個冒號）
        #expect(timeFormat.count == 8)
        #expect(timeFormat.filter { $0 == ":" }.count == 2)
    }
    
    @Test("連續拍照時間戳記測試")
    func testConsecutiveCaptureTimestamps() async throws {
        // 模擬連續拍三張照片
        var timestamps: [Date] = []
        
        for _ in 1...3 {
            let captureTimestamp = Date()
            timestamps.append(captureTimestamp)
            
            // 每次拍照間隔 0.5 秒
            try await Task.sleep(nanoseconds: 500_000_000)
        }
        
        // 驗證：時間戳記應該依序遞增
        #expect(timestamps[1] > timestamps[0])
        #expect(timestamps[2] > timestamps[1])
        
        // 驗證：每張照片間隔約 0.5 秒（允許 0.1 秒誤差）
        let interval1 = timestamps[1].timeIntervalSince(timestamps[0])
        let interval2 = timestamps[2].timeIntervalSince(timestamps[1])
        
        #expect(interval1 >= 0.4)
        #expect(interval1 <= 0.6)
        #expect(interval2 >= 0.4)
        #expect(interval2 <= 0.6)
    }
    
    @Test("午夜與正午時間格式化測試")
    func testMidnightAndNoonFormatting() async throws {
        let calendar = Calendar.current
        
        // 測試午夜：00:00:00
        var midnightComponents = DateComponents()
        midnightComponents.year = 2026
        midnightComponents.month = 2
        midnightComponents.day = 15
        midnightComponents.hour = 0
        midnightComponents.minute = 0
        midnightComponents.second = 0
        midnightComponents.timeZone = TimeZone.current
        
        let midnightDate = try #require(calendar.date(from: midnightComponents))
        #expect(midnightDate.formattedTime() == "00:00:00")
        
        // 測試正午：12:00:00
        var noonComponents = DateComponents()
        noonComponents.year = 2026
        noonComponents.month = 2
        noonComponents.day = 15
        noonComponents.hour = 12
        noonComponents.minute = 0
        noonComponents.second = 0
        noonComponents.timeZone = TimeZone.current
        
        let noonDate = try #require(calendar.date(from: noonComponents))
        #expect(noonDate.formattedTime() == "12:00:00")
    }
}
