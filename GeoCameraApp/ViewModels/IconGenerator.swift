//
//  IconGenerator.swift
//  GeoCameraApp
//
//  Created by Claude on 2026/02/14.
//
//  用於生成 App Icon 的工具
//  運行此代碼後，會在 Documents 目錄生成 App Icon
//

import UIKit

class IconGenerator {
    
    /// 生成 GeoCameraApp 的 Icon
    /// - Parameter size: Icon 尺寸
    /// - Returns: UIImage
    static func generateAppIcon(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            let ctx = context.cgContext
            
            // 1. 背景漸層 (藍色到深藍色 - 代表天空)
            let colors = [
                UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0).cgColor,
                UIColor(red: 0.1, green: 0.2, blue: 0.5, alpha: 1.0).cgColor
            ]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                     colors: colors as CFArray,
                                     locations: [0.0, 1.0])!
            
            ctx.drawLinearGradient(gradient,
                                  start: CGPoint(x: 0, y: 0),
                                  end: CGPoint(x: 0, y: size.height),
                                  options: [])
            
            // 2. 相機鏡頭外框 (白色圓圈)
            let cameraSize = size.width * 0.5
            let cameraRect = CGRect(x: (size.width - cameraSize) / 2,
                                   y: size.height * 0.25,
                                   width: cameraSize,
                                   height: cameraSize)
            
            ctx.setFillColor(UIColor.white.cgColor)
            ctx.fillEllipse(in: cameraRect)
            
            // 3. 鏡頭內圈 (深灰色)
            let lensInset: CGFloat = cameraSize * 0.15
            let lensRect = cameraRect.insetBy(dx: lensInset, dy: lensInset)
            ctx.setFillColor(UIColor(white: 0.3, alpha: 1.0).cgColor)
            ctx.fillEllipse(in: lensRect)
            
            // 4. 鏡頭光澤 (白色高光)
            let highlightSize = cameraSize * 0.2
            let highlightRect = CGRect(x: lensRect.midX - highlightSize * 0.3,
                                      y: lensRect.midY - highlightSize * 0.8,
                                      width: highlightSize,
                                      height: highlightSize)
            ctx.setFillColor(UIColor.white.withAlphaComponent(0.4).cgColor)
            ctx.fillEllipse(in: highlightRect)
            
            // 5. 快門按鈕 (紅色小圓點)
            let shutterSize = size.width * 0.12
            let shutterRect = CGRect(x: size.width * 0.75,
                                    y: size.height * 0.2,
                                    width: shutterSize,
                                    height: shutterSize)
            ctx.setFillColor(UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0).cgColor)
            ctx.fillEllipse(in: shutterRect)
            
            // 6. GPS 定位圖標 (簡化的位置標記)
            drawLocationPin(in: ctx, at: CGPoint(x: size.width * 0.5, y: size.height * 0.7), size: size.width * 0.3)
            
            // 7. 添加文字 "GEO" (在底部)
            let fontSize = size.width * 0.12
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: fontSize, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let text = "GEO" as NSString
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(x: (size.width - textSize.width) / 2,
                                 y: size.height * 0.88,
                                 width: textSize.width,
                                 height: textSize.height)
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
    
    /// 繪製位置標記圖標
    private static func drawLocationPin(in context: CGContext, at center: CGPoint, size: CGFloat) {
        // 外圈 (白色)
        let outerPath = UIBezierPath()
        outerPath.move(to: CGPoint(x: center.x, y: center.y + size * 0.5))
        outerPath.addCurve(to: CGPoint(x: center.x - size * 0.4, y: center.y - size * 0.2),
                          controlPoint1: CGPoint(x: center.x - size * 0.3, y: center.y + size * 0.3),
                          controlPoint2: CGPoint(x: center.x - size * 0.4, y: center.y))
        outerPath.addArc(withCenter: center,
                        radius: size * 0.4,
                        startAngle: .pi,
                        endAngle: 0,
                        clockwise: true)
        outerPath.addCurve(to: CGPoint(x: center.x, y: center.y + size * 0.5),
                          controlPoint1: CGPoint(x: center.x + size * 0.4, y: center.y),
                          controlPoint2: CGPoint(x: center.x + size * 0.3, y: center.y + size * 0.3))
        outerPath.close()
        
        context.setFillColor(UIColor.white.cgColor)
        context.addPath(outerPath.cgPath)
        context.fillPath()
        
        // 內圈 (橙色)
        let innerCircle = CGRect(x: center.x - size * 0.2,
                                y: center.y - size * 0.3,
                                width: size * 0.4,
                                height: size * 0.4)
        context.setFillColor(UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0).cgColor)
        context.fillEllipse(in: innerCircle)
    }
    
    /// 生成所有尺寸的 Icon 並保存到 Documents
    static func generateAllIcons() {
        let sizes: [(String, CGFloat)] = [
            ("Icon-20@2x", 40),
            ("Icon-20@3x", 60),
            ("Icon-29@2x", 58),
            ("Icon-29@3x", 87),
            ("Icon-40@2x", 80),
            ("Icon-40@3x", 120),
            ("Icon-60@2x", 120),
            ("Icon-60@3x", 180),
            ("Icon-1024", 1024)
        ]
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let iconFolder = documentsPath.appendingPathComponent("GeoCameraIcons")
        
        try? FileManager.default.createDirectory(at: iconFolder, withIntermediateDirectories: true)
        
        for (name, size) in sizes {
            let icon = generateAppIcon(size: CGSize(width: size, height: size))
            
            if let data = icon.pngData() {
                let fileURL = iconFolder.appendingPathComponent("\(name).png")
                try? data.write(to: fileURL)
                print("✅ 生成 Icon: \(name).png")
            }
        }
        
        print("📁 Icon 已保存到: \(iconFolder.path)")
        print("🎯 請將這些檔案拖拽到 Xcode 的 Assets.xcassets/AppIcon")
    }
}

// MARK: - 使用範例

#if DEBUG
extension IconGenerator {
    /// 在 SwiftUI Preview 中預覽 Icon
    static func previewIcon() -> UIImage {
        return generateAppIcon(size: CGSize(width: 1024, height: 1024))
    }
}
#endif
