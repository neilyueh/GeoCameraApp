//
//  ContentView.swift
//  GeoCameraApp
//
//  Created by Claude on 2026/02/14.
//

import SwiftUI
import AVFoundation

/// 主畫面
struct ContentView: View {
    @StateObject private var viewModel = CameraViewModel()
    @State private var orientation = UIDeviceOrientation.portrait
    
    var body: some View {
        ZStack {
            // 相機預覽層（最底層）
            CameraPreviewViewContainer(viewModel: viewModel)
                .ignoresSafeArea()
            
            // 如果相機未就緒，顯示黑色遮罩
            if viewModel.cameraStatus != .ready {
                Color.black.ignoresSafeArea()
            }

            // 根據狀態顯示不同的覆蓋層
            if viewModel.cameraStatus == .notAuthorized {
                // 相機權限拒絕
                PermissionDeniedView(
                    title: Constants.Strings.Permissions.cameraTitle,
                    message: Constants.Strings.Permissions.cameraMessage
                )
            } else if viewModel.locationStatus == .notAuthorized {
                // 位置權限拒絕
                PermissionDeniedView(
                    title: Constants.Strings.Permissions.locationTitle,
                    message: Constants.Strings.Permissions.locationMessage
                )
            } else if viewModel.cameraStatus == .configuring {
                // 載入中
                LoadingView(message: Constants.Strings.Status.cameraConfiguring)
            } else if viewModel.cameraStatus == .ready {
                // 正常操作界面
                mainCameraInterface
            }

            // 成功提示（浮動在最上層）
            if viewModel.showSuccessAlert {
                successAlert
            }
        }
        .onAppear {
            viewModel.startServices()
            // 開始監聽方向變化
            startOrientationObserver()
        }
        .onDisappear {
            viewModel.stopServices()
            // 停止監聽方向變化
            stopOrientationObserver()
        }
        .alert(isPresented: .constant(viewModel.errorMessage != nil)) {
            Alert(
                title: Text("錯誤"),
                message: Text(viewModel.errorMessage ?? ""),
                dismissButton: .default(Text("確定")) {
                    viewModel.errorMessage = nil
                }
            )
        }
    }
    
    // MARK: - Orientation Detection
    
    private func startOrientationObserver() {
        // 啟用裝置方向通知
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
        // 監聽方向變化
        NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            let newOrientation = UIDevice.current.orientation
            // 只處理有效的方向（排除 unknown, faceUp, faceDown）
            if newOrientation.isValidInterfaceOrientation {
                orientation = newOrientation
                viewModel.deviceOrientation = newOrientation
                print("📱 裝置方向變更: \(orientationName(newOrientation))")
            }
        }
    }
    
    private func stopOrientationObserver() {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
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

    // MARK: - Main Camera Interface

    private var mainCameraInterface: some View {
        ZStack {
            // 資訊顯示（右下角）
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    InfoOverlayView(
                        date: viewModel.displayDate,
                        time: viewModel.displayTime,
                        latLong: viewModel.displayLatLong,
                        address: viewModel.displayAddress
                    )
                    .padding(Constants.UI.screenEdgePadding)
                }
            }

            // 拍照按鈕 - 根據方向動態調整位置
            captureButtonLayout
            
            // 拍照中覆蓋層
            if viewModel.isCaptureInProgress {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .overlay(
                        ProgressView()
                            .scaleEffect(2)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    )
            }
        }
    }
    
    // MARK: - Capture Button Layout
    
    @ViewBuilder
    private var captureButtonLayout: some View {
        if isLandscape {
            // 橫向模式：按鈕在右側中央
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    CaptureButtonView(
                        action: viewModel.capturePhoto,
                        isEnabled: viewModel.canCapture
                    )
                    Spacer()
                }
                .padding(.trailing, 30)
            }
            .transition(.move(edge: .trailing))
        } else {
            // 直立模式：按鈕在底部中央
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    CaptureButtonView(
                        action: viewModel.capturePhoto,
                        isEnabled: viewModel.canCapture
                    )
                    Spacer()
                }
                .padding(.bottom, 50)
            }
            .transition(.move(edge: .bottom))
        }
    }
    
    // 判斷是否為橫向模式
    private var isLandscape: Bool {
        return orientation.isLandscape
    }

    // MARK: - Success Alert

    private var successAlert: some View {
        VStack {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)

                Text(Constants.Strings.Success.photoSaved)
                    .fontWeight(.semibold)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(radius: 10)
            )
            .padding(.top, 60)

            Spacer()
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.easeInOut, value: viewModel.showSuccessAlert)
    }
}

// MARK: - Camera Preview Container

/// 相機預覽容器，確保 preview layer 只被創建一次
struct CameraPreviewViewContainer: View {
    @ObservedObject var viewModel: CameraViewModel
    
    // 使用 @State 確保 preview layer 只創建一次
    @State private var previewLayer: AVCaptureVideoPreviewLayer?
    
    var body: some View {
        Group {
            if let layer = previewLayer {
                CameraPreviewView(previewLayer: layer)
            } else {
                Color.black
                    .onAppear {
                        // 只在首次出現時創建 preview layer
                        previewLayer = viewModel.getCameraPreviewLayer()
                    }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
