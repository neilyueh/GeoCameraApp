//
//  IconGeneratorView.swift
//  GeoCameraApp
//
//  Created by Claude on 2026/02/14.
//
//  用於預覽和生成 App Icon 的介面
//

import SwiftUI

struct IconGeneratorView: View {
    @State private var generatedIcon: UIImage?
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 30) {
            Text("GeoCameraApp Icon Generator")
                .font(.title)
                .fontWeight(.bold)
            
            // 預覽 Icon
            if let icon = generatedIcon {
                Image(uiImage: icon)
                    .resizable()
                    .frame(width: 200, height: 200)
                    .cornerRadius(44) // iOS Icon 圓角
                    .shadow(radius: 10)
            } else {
                RoundedRectangle(cornerRadius: 44)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 200, height: 200)
                    .overlay(
                        Text("點擊下方按鈕\n生成預覽")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(spacing: 15) {
                // 預覽按鈕
                Button(action: {
                    generatedIcon = IconGenerator.previewIcon()
                }) {
                    HStack {
                        Image(systemName: "eye.fill")
                        Text("預覽 Icon")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                // 生成所有尺寸按鈕
                Button(action: {
                    IconGenerator.generateAllIcons()
                    alertMessage = "所有 Icon 已生成！\n請到「檔案」App 中的 Documents/GeoCameraIcons 資料夾查看"
                    showAlert = true
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down.fill")
                        Text("生成所有尺寸")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                // 說明文字
                VStack(alignment: .leading, spacing: 8) {
                    Text("📌 使用說明：")
                        .font(.headline)
                    
                    Text("1. 點擊「預覽 Icon」查看效果")
                        .font(.caption)
                    
                    Text("2. 點擊「生成所有尺寸」創建所有需要的圖標")
                        .font(.caption)
                    
                    Text("3. 到「檔案」App 找到圖標檔案")
                        .font(.caption)
                    
                    Text("4. 將圖標拖入 Xcode 的 Assets.xcassets/AppIcon")
                        .font(.caption)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
        .padding()
        .alert("完成", isPresented: $showAlert) {
            Button("確定", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct IconGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        IconGeneratorView()
    }
}
#endif
