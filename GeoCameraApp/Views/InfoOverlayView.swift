//
//  InfoOverlayView.swift
//  GeoCameraApp
//
//  Created by Claude on 2026/02/14.
//

import SwiftUI

/// 資訊疊加視圖（顯示在右下角）
struct InfoOverlayView: View {
    let date: String
    let time: String
    let latLong: String
    let address: String
    var isLandscape: Bool = false  // 新增參數來控制旋轉

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.UI.lineSpacing) {
            Text(date)
            Text(time)
            Text(latLong)
            Text(address)
                .lineLimit(2)
        }
        .font(.system(size: Constants.UI.fontSize, weight: .medium))
        .foregroundColor(Constants.Colors.infoText)
        .padding(Constants.UI.infoPadding)
        .background(
            RoundedRectangle(cornerRadius: Constants.UI.infoCornerRadius)
                .fill(Constants.Colors.infoBackground)
        )
        .rotationEffect(.degrees(isLandscape ? 90 : 0))  // 橫向時旋轉90度
    }
}

// MARK: - Preview

#if DEBUG
struct InfoOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.ignoresSafeArea()

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    InfoOverlayView(
                        date: "2026/02/14",
                        time: "14:30:25",
                        latLong: "25.033964, 121.564472",
                        address: "台北市信義區信義路五段7號"
                    )
                    .padding(Constants.UI.screenEdgePadding)
                }
            }
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
