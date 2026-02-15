//
//  PhotoService.swift
//  GeoCameraApp
//
//  Created by Claude on 2026/02/14.
//

import UIKit
import Photos

/// 照片服務協議
protocol PhotoServiceProtocol {
    /// 添加浮水印到照片
    /// - Parameters:
    ///   - image: 原始照片
    ///   - locationInfo: 地理資訊
    ///   - deviceOrientation: 裝置方向（用於旋轉浮水印）
    /// - Returns: 加上浮水印的照片
    func addWatermark(to image: UIImage, with locationInfo: LocationInfo, deviceOrientation: UIDeviceOrientation) -> UIImage

    /// 儲存照片到相簿
    /// - Parameter image: 要儲存的照片
    /// - Throws: 儲存失敗的錯誤
    func saveToPhotoLibrary(_ image: UIImage) async throws
}

/// 照片服務實作
class PhotoService: PhotoServiceProtocol {
    // MARK: - Public Methods

    func addWatermark(to image: UIImage, with locationInfo: LocationInfo, deviceOrientation: UIDeviceOrientation) -> UIImage {
        print("🎨 添加浮水印: \(locationInfo.formattedDate) \(locationInfo.formattedTime)")
        print("  - 裝置方向: \(orientationName(deviceOrientation))")
        
        // 先正規化圖片方向（處理旋轉問題）
        let normalizedImage = normalizeImageOrientation(image)
        
        // 使用 UIGraphicsImageRenderer 建立新圖像
        let format = UIGraphicsImageRendererFormat()
        format.scale = normalizedImage.scale
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: normalizedImage.size, format: format)

        let result = renderer.image { context in
            // 1. 繪製原始照片
            normalizedImage.draw(at: .zero)

            // 2. 準備文字資訊（四行）
            let lines = [
                locationInfo.formattedDate,
                locationInfo.formattedTime,
                locationInfo.formattedLatLong,
                locationInfo.displayAddress
            ]

            // 3. 根據裝置方向決定浮水印的繪製方式
            if deviceOrientation.isLandscape {
                print("  - 橫向模式：浮水印需要旋轉")
                drawRotatedWatermark(
                    in: context.cgContext,
                    lines: lines,
                    imageSize: normalizedImage.size,
                    deviceOrientation: deviceOrientation
                )
            } else {
                print("  - 直立模式：浮水印正常繪製")
                drawNormalWatermark(
                    lines: lines,
                    imageSize: normalizedImage.size
                )
            }
        }
        
        print("✅ 浮水印添加完成")
        return result
    }
    
    // MARK: - Helper Methods
    
    /// 繪製正常方向的浮水印（直立模式）
    private func drawNormalWatermark(lines: [String], imageSize: CGSize) {
        // 設定文字樣式
        var baseFontSize = max(imageSize.width * 0.03, 40)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineSpacing = 8
        
        let lineHeight: CGFloat = baseFontSize + 8
        let padding: CGFloat = 20
        let margin: CGFloat = 40
        
        // 🔧 計算可用寬度（確保不會超出畫面）
        let availableWidth = imageSize.width - margin * 2 - padding * 2
        
        print("  - 圖片尺寸: \(imageSize)")
        print("  - 可用寬度: \(availableWidth)")
        
        // 🔧 自適應計算字體大小和文字寬度
        var attributes: [NSAttributedString.Key: Any]
        var maxWidth: CGFloat
        var adjustedLines = lines
        
        // 嘗試調整字體大小，直到文字能夠完全顯示
        repeat {
            attributes = [
                .font: UIFont.systemFont(ofSize: baseFontSize, weight: .bold),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle,
                .strokeColor: UIColor.black,
                .strokeWidth: -2.0
            ]
            
            maxWidth = adjustedLines.map { text in
                (text as NSString).size(withAttributes: attributes).width
            }.max() ?? 0
            
            // 如果文字太長，縮小字體
            if maxWidth > availableWidth && baseFontSize > 20 {
                baseFontSize -= 2
                print("  - 文字過長(\(maxWidth))，縮小字體至: \(baseFontSize)")
            } else {
                break
            }
        } while baseFontSize > 20
        
        // 🔧 如果字體已經很小但還是太長，截斷最長的行（通常是地址）
        if maxWidth > availableWidth {
            print("  - 文字仍過長，嘗試截斷地址")
            adjustedLines = adjustLines(lines, maxWidth: availableWidth, attributes: attributes)
            maxWidth = adjustedLines.map { text in
                (text as NSString).size(withAttributes: attributes).width
            }.max() ?? 0
        }

        let textWidth = maxWidth + padding * 2
        let totalHeight = CGFloat(adjustedLines.count) * lineHeight + padding * 2

        // 計算位置（右下角）
        let x = imageSize.width - textWidth - margin
        let y = imageSize.height - totalHeight - margin
        
        print("  - 浮水印位置: 右下角 (\(x), \(y))")
        print("  - 調整後字體大小: \(baseFontSize)")
        print("  - 文字框尺寸: \(textWidth) x \(totalHeight)")

        // 繪製背景
        let backgroundRect = CGRect(x: x, y: y, width: textWidth, height: totalHeight)
        let backgroundPath = UIBezierPath(roundedRect: backgroundRect, cornerRadius: 12)
        UIColor.black.withAlphaComponent(0.7).setFill()
        backgroundPath.fill()

        // 繪製文字
        for (index, line) in adjustedLines.enumerated() {
            let textY = y + padding + CGFloat(index) * lineHeight
            let textRect = CGRect(x: x + padding, y: textY, width: maxWidth, height: lineHeight)
            (line as NSString).draw(in: textRect, withAttributes: attributes)
        }
    }
    
    /// 繪製旋轉的浮水印（橫向模式）
    private func drawRotatedWatermark(in context: CGContext, lines: [String], imageSize: CGSize, deviceOrientation: UIDeviceOrientation) {
        context.saveGState()
        
        // 設定文字樣式（橫向時使用較小的字體）
        var baseFontSize = max(imageSize.height * 0.03, 40)  // 注意：橫向時使用 height
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineSpacing = 8
        
        let lineHeight: CGFloat = baseFontSize + 8
        let padding: CGFloat = 20
        let margin: CGFloat = 40
        
        // 🔧 修復關鍵：計算旋轉後可用的最大寬度
        // 當浮水印旋轉 90° 後，它的「寬度」會變成在圖片「高度」方向上的長度
        // 因此，我們需要確保文字寬度不超過圖片的高度
        let availableWidth = imageSize.height - margin * 2 - 200  // 預留更多邊距避免被截斷
        
        print("  - 圖片尺寸: \(imageSize)")
        print("  - 可用寬度: \(availableWidth)")
        
        // 🔧 自適應計算字體大小和文字寬度
        var attributes: [NSAttributedString.Key: Any]
        var maxWidth: CGFloat
        var adjustedLines = lines
        
        // 嘗試調整字體大小，直到文字能夠完全顯示
        repeat {
            attributes = [
                .font: UIFont.systemFont(ofSize: baseFontSize, weight: .bold),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle,
                .strokeColor: UIColor.black,
                .strokeWidth: -2.0
            ]
            
            maxWidth = adjustedLines.map { text in
                (text as NSString).size(withAttributes: attributes).width
            }.max() ?? 0
            
            // 如果文字太長，縮小字體
            if maxWidth > availableWidth && baseFontSize > 20 {
                baseFontSize -= 2
                print("  - 文字過長(\(maxWidth))，縮小字體至: \(baseFontSize)")
            } else {
                break
            }
        } while baseFontSize > 20
        
        // 🔧 如果字體已經很小但還是太長，截斷最長的行（通常是地址）
        if maxWidth > availableWidth {
            print("  - 文字仍過長，嘗試截斷地址")
            adjustedLines = adjustLines(lines, maxWidth: availableWidth, attributes: attributes)
            maxWidth = adjustedLines.map { text in
                (text as NSString).size(withAttributes: attributes).width
            }.max() ?? 0
        }
        
        let textWidth = maxWidth + padding * 2
        let totalHeight = CGFloat(adjustedLines.count) * lineHeight + padding * 2
        
        print("  - 調整後文字寬度: \(textWidth)")
        print("  - 調整後字體大小: \(baseFontSize)")

        // 橫向模式：浮水印在左側中央偏下
        // 需要旋轉 90 度使文字水平顯示
        let bottomOffset: CGFloat = 100  // 向上偏移，避開拍照按鈕
        
        var rotationAngle: CGFloat = 0
        var translationX: CGFloat = 0
        var translationY: CGFloat = 0
        
        if deviceOrientation == .landscapeLeft {
            // Home 鍵在左側 → 相機拍攝時，文字需要順時針旋轉 90 度
            // 浮水印位置：左側中央偏下
            rotationAngle = .pi / 2
            translationX = margin + totalHeight
            translationY = (imageSize.height + textWidth) / 2 + bottomOffset
            
            // 🔧 確保不會超出右邊界
            if translationY + textWidth > imageSize.height {
                translationY = imageSize.height - textWidth - margin
                print("  - 調整 Y 位置避免超出邊界: \(translationY)")
            }
            
            print("  - 橫向左：順時針旋轉 90°，左側中央")
        } else if deviceOrientation == .landscapeRight {
            // Home 鍵在右側 → 相機拍攝時，文字需要逆時針旋轉 90 度
            // 浮水印位置：左側中央偏下
            rotationAngle = -.pi / 2
            translationX = margin
            translationY = (imageSize.height - textWidth) / 2 - bottomOffset
            
            // 🔧 確保不會超出左邊界
            if translationY - textWidth < 0 {
                translationY = textWidth + margin
                print("  - 調整 Y 位置避免超出邊界: \(translationY)")
            }
            
            print("  - 橫向右：逆時針旋轉 90°，左側中央")
        }
        
        print("  - 旋轉角度: \(rotationAngle * 180 / .pi)°")
        print("  - 最終位置: (\(translationX), \(translationY))")
        print("  - 文字框尺寸: \(textWidth) x \(totalHeight)")
        
        // 移動到目標位置並旋轉
        context.translateBy(x: translationX, y: translationY)
        context.rotate(by: rotationAngle)
        
        // 繪製背景
        let backgroundRect = CGRect(x: 0, y: 0, width: textWidth, height: totalHeight)
        let backgroundPath = UIBezierPath(roundedRect: backgroundRect, cornerRadius: 12)
        UIColor.black.withAlphaComponent(0.7).setFill()
        backgroundPath.fill()

        // 繪製文字
        for (index, line) in adjustedLines.enumerated() {
            let textY = padding + CGFloat(index) * lineHeight
            let textRect = CGRect(x: padding, y: textY, width: maxWidth, height: lineHeight)
            (line as NSString).draw(in: textRect, withAttributes: attributes)
        }
        
        context.restoreGState()
    }
    
    /// 調整文字行，確保不超過最大寬度
    private func adjustLines(_ lines: [String], maxWidth: CGFloat, attributes: [NSAttributedString.Key: Any]) -> [String] {
        return lines.map { line in
            let lineWidth = (line as NSString).size(withAttributes: attributes).width
            if lineWidth <= maxWidth {
                return line
            }
            
            // 二分搜尋找到合適的截斷位置
            var left = 0
            var right = line.count
            var bestLength = 0
            
            while left <= right {
                let mid = (left + right) / 2
                let index = line.index(line.startIndex, offsetBy: mid)
                let substring = String(line[..<index]) + "..."
                let width = (substring as NSString).size(withAttributes: attributes).width
                
                if width <= maxWidth {
                    bestLength = mid
                    left = mid + 1
                } else {
                    right = mid - 1
                }
            }
            
            if bestLength > 0 {
                let index = line.index(line.startIndex, offsetBy: bestLength)
                return String(line[..<index]) + "..."
            } else {
                return "..."
            }
        }
    }
    
    private func orientationName(_ orientation: UIDeviceOrientation) -> String {
        switch orientation {
        case .portrait: return "直立"
        case .portraitUpsideDown: return "倒立"
        case .landscapeLeft: return "橫向左"
        case .landscapeRight: return "橫向右"
        case .faceUp: return "平放向上"
        case .faceDown: return "平放向下"
        default: return "未知"
        }
    }
    
    /// 正規化圖片方向，確保圖片以正確的方向顯示
    private func normalizeImageOrientation(_ image: UIImage) -> UIImage {
        // 如果方向已經是 up，直接返回
        if image.imageOrientation == .up {
            return image
        }
        
        // 創建新的圖片，方向為 up
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
    }

    func saveToPhotoLibrary(_ image: UIImage) async throws {
        // 檢查相簿權限
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)

        switch status {
        case .authorized, .limited:
            // 已授權，直接儲存
            try await performSave(image)

        case .notDetermined:
            // 請求權限
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            if newStatus == .authorized || newStatus == .limited {
                try await performSave(image)
            } else {
                throw NSError(
                    domain: "PhotoService",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "未授權相簿權限"]
                )
            }

        case .denied, .restricted:
            throw NSError(
                domain: "PhotoService",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "未授權相簿權限"]
            )

        @unknown default:
            throw NSError(
                domain: "PhotoService",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "未知的授權狀態"]
            )
        }
    }

    // MARK: - Private Methods

    private func performSave(_ image: UIImage) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }
    }
}

// MARK: - UIImage Extension for Watermark

extension UIImage {
    /// 為照片添加浮水印的便利方法
    /// - Parameters:
    ///   - locationInfo: 位置資訊
    ///   - deviceOrientation: 裝置方向
    /// - Returns: 加上浮水印的照片
    func withWatermark(locationInfo: LocationInfo, deviceOrientation: UIDeviceOrientation = .portrait) -> UIImage {
        let photoService = PhotoService()
        return photoService.addWatermark(to: self, with: locationInfo, deviceOrientation: deviceOrientation)
    }
}
