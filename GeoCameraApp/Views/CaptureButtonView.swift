//
//  CaptureButtonView.swift
//  GeoCameraApp
//
//  Created by Claude on 2026/02/14.
//

import SwiftUI

/// 拍照按鈕視圖
struct CaptureButtonView: View {
    let action: () -> Void
    let isEnabled: Bool

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            guard isEnabled else { return }

            // 點擊動畫
            withAnimation(.easeInOut(duration: Constants.Animation.buttonTapDuration)) {
                isPressed = true
            }

            // 執行動作
            action()

            // 恢復按鈕狀態
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Animation.buttonTapDuration) {
                withAnimation(.easeInOut(duration: Constants.Animation.buttonTapDuration)) {
                    isPressed = false
                }
            }
        }) {
            ZStack {
                // 外圈
                Circle()
                    .stroke(Constants.Colors.captureButtonBorder,
                           lineWidth: Constants.UI.captureButtonBorderWidth)
                    .frame(width: Constants.UI.captureButtonSize,
                          height: Constants.UI.captureButtonSize)

                // 內圈
                Circle()
                    .fill(isEnabled ? Constants.Colors.captureButton : Constants.Colors.captureButton.opacity(0.5))
                    .frame(width: Constants.UI.captureButtonSize - 12,
                          height: Constants.UI.captureButtonSize - 12)
            }
            .scaleEffect(isPressed ? Constants.Animation.buttonTapScale : 1.0)
            .opacity(isEnabled ? 1.0 : 0.6)
        }
        .disabled(!isEnabled)
    }
}

// MARK: - Preview

#if DEBUG
struct CaptureButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 40) {
                // 啟用狀態
                CaptureButtonView(action: {
                    print("拍照！")
                }, isEnabled: true)

                // 禁用狀態
                CaptureButtonView(action: {
                    print("拍照！")
                }, isEnabled: false)
            }
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
