//
//  LoadingView.swift
//  GeoCameraApp
//
//  Created by Claude on 2026/02/14.
//

import SwiftUI

/// 載入中視圖
struct LoadingView: View {
    let message: String

    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .white))

            Text(message)
                .font(.body)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.8))
    }
}

// MARK: - Preview

#if DEBUG
struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoadingView(message: Constants.Strings.Status.cameraConfiguring)

            LoadingView(message: Constants.Strings.Status.locationLocating)
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
