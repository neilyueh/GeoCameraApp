//
//  Constants.swift
//  GeoCameraApp
//
//  Created by Claude on 2026/02/14.
//

import SwiftUI
import CoreLocation
import AVFoundation
import AudioToolbox

/// App 全域常數
enum Constants {
    // MARK: - UI Constants

    /// UI 常數
    enum UI {
        /// 拍照按鈕尺寸
        static let captureButtonSize: CGFloat = 75

        /// 拍照按鈕邊框寬度
        static let captureButtonBorderWidth: CGFloat = 4

        /// 資訊顯示區域的圓角半徑
        static let infoCornerRadius: CGFloat = 8

        /// 資訊顯示區域的內距
        static let infoPadding: CGFloat = 12

        /// 文字行距
        static let lineSpacing: CGFloat = 6

        /// 字型大小
        static let fontSize: CGFloat = 16

        /// 資訊顯示區域距離螢幕邊緣的距離
        static let screenEdgePadding: CGFloat = 20
    }

    // MARK: - Color Constants

    /// 顏色常數
    enum Colors {
        /// 資訊文字顏色（白色）
        static let infoText = Color.white

        /// 資訊背景顏色（黑色 60% 不透明度）
        static let infoBackground = Color.black.opacity(0.6)

        /// 拍照按鈕顏色（白色）
        static let captureButton = Color.white

        /// 拍照按鈕邊框顏色（白色）
        static let captureButtonBorder = Color.white

        /// 錯誤提示顏色（紅色）
        static let error = Color.red

        /// 成功提示顏色（綠色）
        static let success = Color.green
    }

    // MARK: - Format Constants

    /// 格式常數
    enum Formats {
        /// 日期格式（YYYY/MM/DD）
        static let date = "yyyy/MM/dd"

        /// 時間格式（HH:mm:ss，24小時制）
        static let time = "HH:mm:ss"

        /// 經緯度格式（小數點後 6 位）
        static let coordinate = "%.6f"

        /// 經緯度顯示格式
        static let latLongFormat = "%.6f, %.6f"
    }

    // MARK: - String Constants

    /// 文字常數
    enum Strings {
        /// 權限相關
        enum Permissions {
            static let cameraTitle = "需要相機權限"
            static let cameraMessage = "此 App 需要使用相機來拍攝照片。請到「設定」中開啟相機權限。"
            static let locationTitle = "需要位置權限"
            static let locationMessage = "此 App 需要取得位置資訊。請到「設定」中開啟位置權限。"
            static let photoLibraryTitle = "需要相簿權限"
            static let photoLibraryMessage = "此 App 需要儲存照片到相簿。請到「設定」中開啟相簿權限。"
            static let goToSettings = "前往設定"
            static let cancel = "取消"
        }

        /// 狀態訊息
        enum Status {
            static let cameraConfiguring = "正在啟動相機..."
            static let locationLocating = "正在定位中..."
            static let addressResolving = "正在取得地址..."
            static let addressUnavailable = "無法取得地址"
            static let capturing = "拍照中..."
            static let saving = "儲存中..."
        }

        /// 錯誤訊息
        enum Errors {
            static let cameraUnavailable = "相機無法使用"
            static let locationUnavailable = "無法取得位置"
            static let photoSaveFailed = "照片儲存失敗"
            static let unknownError = "發生未知錯誤"
        }

        /// 成功訊息
        enum Success {
            static let photoSaved = "照片已儲存"
        }
    }

    // MARK: - GPS Constants

    /// GPS 常數
    enum GPS {
        /// 位置準確度（最佳）
        static let desiredAccuracy = kCLLocationAccuracyBest

        /// 位置更新距離過濾（10 公尺）
        static let distanceFilter: Double = 10

        /// 地理編碼超時時間（5 秒）
        static let geocodingTimeout: TimeInterval = 5
    }

    // MARK: - Camera Constants

    /// 相機常數
    enum Camera {
        /// 照片品質設定
        static let photoQualityPrioritization = AVCapturePhotoOutput.QualityPrioritization.balanced

        /// 最大照片解析度寬度
        static let maxPhotoWidth: CGFloat = 1920

        /// 最大照片解析度高度
        static let maxPhotoHeight: CGFloat = 1080
    }

    // MARK: - Audio Constants

    /// 聲音常數
    enum Audio {
        /// 系統快門聲音 ID
        static let shutterSoundID: SystemSoundID = 1108
    }

    // MARK: - Animation Constants

    /// 動畫常數
    enum Animation {
        /// 按鈕點擊動畫時長
        static let buttonTapDuration: Double = 0.1

        /// 按鈕點擊縮放比例
        static let buttonTapScale: CGFloat = 0.9

        /// 成功提示顯示時長
        static let successAlertDuration: Double = 2.0

        /// 淡入淡出動畫時長
        static let fadeDuration: Double = 0.3
    }
}
