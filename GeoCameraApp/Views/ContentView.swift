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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    // 追蹤設備方向
    @State private var deviceOrientation: UIDeviceOrientation = UIDevice.current.orientation

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
            startOrientationMonitoring()
        }
        .onDisappear {
            viewModel.stopServices()
            stopOrientationMonitoring()
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

    // MARK: - Main Camera Interface

    private var mainCameraInterface: some View {
        ZStack {
            // 資訊顯示 - 根據方向動態調整位置並旋轉
            infoOverlayView
            
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
    
    // MARK: - Info Overlay with Rotation
    
    @ViewBuilder
    private var infoOverlayView: some View {
        GeometryReader { geometry in
            if isLandscape {
                // 橫向模式：資訊在左側（旋轉90度後文字水平顯示）
                HStack {
                    VStack {
                        Spacer()
                        InfoOverlayView(
                            date: viewModel.displayDate,
                            time: viewModel.displayTime,
                            latLong: viewModel.displayLatLong,
                            address: viewModel.displayAddress,
                            isLandscape: true  // 告訴 InfoOverlayView 需要旋轉
                        )
                        Spacer()
                    }
                    .padding(.leading, Constants.UI.screenEdgePadding)
                    // 向上偏移一點，避開底部的拍照按鈕區域
                    .padding(.bottom, 100)
                    
                    Spacer()
                }
            } else {
                // 直立模式：資訊在右下角，位於快門按鈕上方，避免重疊
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        InfoOverlayView(
                            date: viewModel.displayDate,
                            time: viewModel.displayTime,
                            latLong: viewModel.displayLatLong,
                            address: viewModel.displayAddress,
                            isLandscape: false
                        )
                        .padding(.trailing, Constants.UI.screenEdgePadding)
                    }
                    // 為快門按鈕留出空間，避免重疊
                    // 按鈕高度(80) + 底部padding(50) + 安全間距(20)
                    .padding(.bottom, 150)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isLandscape)
    }
    
    // MARK: - Capture Button Layout
    
    @ViewBuilder
    private var captureButtonLayout: some View {
        // 按鈕始終在底部中央，不管方向如何
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
    }
    
    // 判斷是否為橫向模式
    private var isLandscape: Bool {
        return deviceOrientation.isLandscape
    }
    
    // MARK: - Orientation Monitoring
    
    private func startOrientationMonitoring() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main
        ) { [self] _ in
            let newOrientation = UIDevice.current.orientation
            // 只在有效的方向時更新
            if newOrientation.isPortrait || newOrientation.isLandscape {
                deviceOrientation = newOrientation
                // 同步更新 ViewModel 的方向
                viewModel.deviceOrientation = newOrientation
            }
        }
        
        // 設置初始方向
        let initialOrientation = UIDevice.current.orientation
        if initialOrientation.isPortrait || initialOrientation.isLandscape {
            deviceOrientation = initialOrientation
            viewModel.deviceOrientation = initialOrientation
        } else {
            // 如果初始方向未知，默認為直立
            deviceOrientation = .portrait
            viewModel.deviceOrientation = .portrait
        }
    }
    
    private func stopOrientationMonitoring() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
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
