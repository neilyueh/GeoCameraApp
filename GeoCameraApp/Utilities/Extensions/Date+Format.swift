//
//  Date+Format.swift
//  GeoCameraApp
//
//  Created by Claude on 2026/02/14.
//

import Foundation

extension Date {
    /// 格式化為 YYYY/MM/DD 格式
    /// - Returns: 格式化的日期字串，例如：2026/02/14
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.timeZone = TimeZone.current
        return formatter.string(from: self)
    }

    /// 格式化為 HH:mm:ss 格式（24小時制）
    /// - Returns: 格式化的時間字串，例如：14:30:25
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.timeZone = TimeZone.current
        return formatter.string(from: self)
    }

    /// 格式化為完整的日期時間字串
    /// - Returns: 格式化的日期時間字串，例如：2026/02/14 14:30:25
    func formattedDateTime() -> String {
        return "\(formattedDate()) \(formattedTime())"
    }

    /// 格式化為 ISO8601 格式（用於記錄和除錯）
    /// - Returns: ISO8601 格式字串，例如：2026-02-14T14:30:25+08:00
    func iso8601String() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone.current
        return formatter.string(from: self)
    }
}
