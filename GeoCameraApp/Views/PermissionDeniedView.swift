//
//  PermissionDeniedView.swift
//  GeoCameraApp
//
//  Created by Claude on 2026/02/14.
//

import SwiftUI

/// 權限拒絕提示視圖
struct PermissionDeniedView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)

            Text(title)
                .font(.title2)
                .fontWeight(.bold)

            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)

            Button(action: {
                // 開啟系統設定
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text(Constants.Strings.Permissions.goToSettings)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            .padding(.top, 8)
        }
        .padding()
    }
}

// MARK: - Preview

#if DEBUG
struct PermissionDeniedView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PermissionDeniedView(
                title: Constants.Strings.Permissions.cameraTitle,
                message: Constants.Strings.Permissions.cameraMessage
            )

            PermissionDeniedView(
                title: Constants.Strings.Permissions.locationTitle,
                message: Constants.Strings.Permissions.locationMessage
            )
            .preferredColorScheme(.dark)
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
