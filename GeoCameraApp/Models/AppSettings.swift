//
//  AppSettings.swift
//  GeoCameraApp
//
//  Created by Claude on 2026/02/14.
//

import SwiftUI

/// App 設定模型
/// 定義 UI 樣式和格式化選項
struct AppSettings {
    // MARK: - 日期時間格式

    /// 日期格式（預設：yyyy/MM/dd）
    var dateFormat: String = "yyyy/MM/dd"

    /// 時間格式（預設：HH:mm:ss，24小時制）
    var timeFormat: String = "HH:mm:ss"

    // MARK: - UI 樣式

    /// 文字顏色（預設：白色）
    var textColor: Color = .white

    /// 背景顏色（預設：黑色，60% 不透明度）
    var backgroundColor: Color = Color.black.opacity(0.6)

    /// 字型大小（預設：16pt）
    var fontSize: CGFloat = 16

    /// 圓角半徑（預設：8pt）
    var cornerRadius: CGFloat = 8

    /// 內距（預設：12pt）
    var padding: CGFloat = 12

    /// 行距（預設：6pt）
    var lineSpacing: CGFloat = 6

    // MARK: - 拍照按鈕樣式

    /// 拍照按鈕直徑（預設：75pt）
    var captureButtonSize: CGFloat = 75

    /// 拍照按鈕邊框寬度（預設：4pt）
    var captureButtonBorderWidth: CGFloat = 4

    // MARK: - Default Instance

    /// 預設設定實例
    static let `default` = AppSettings()
}

// MARK: - Preview Helper

#if DEBUG
extension AppSettings {
    /// 測試用設定（較大的文字）
    static let largeText = AppSettings(
        fontSize: 20,
        padding: 16
    )

    /// 測試用設定（高對比）
    static let highContrast = AppSettings(
        textColor: .yellow,
        backgroundColor: Color.black.opacity(0.8)
    )
}
#endif
