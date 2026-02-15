//
//  CameraViewModel.swift
//  GeoCameraApp
//
//  Created by Claude on 2026/02/14.
//

import SwiftUI
import Combine
import AVFoundation

/// 相機畫面的 ViewModel
@MainActor
class CameraViewModel: ObservableObject {
    // MARK: - Published State

    @Published var cameraStatus: CameraStatus = .configuring
    @Published var locationStatus: LocationStatus = .notAuthorized
    @Published var currentLocationInfo: LocationInfo?
    @Published var isCaptureInProgress: Bool = false
    @Published var errorMessage: String?
    @Published var showSuccessAlert: Bool = false
    @Published var deviceOrientation: UIDeviceOrientation = .portrait

    // MARK: - Services

    private var cameraService: CameraServiceProtocol
    private var locationService: LocationServiceProtocol
    private let geocodingService: GeocodingServiceProtocol
    private let photoService: PhotoServiceProtocol
    private let audioService: AudioServiceProtocol

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties

    /// 顯示用的日期字串
    var displayDate: String {
        currentLocationInfo?.formattedDate ?? "----/--/--"
    }

    /// 顯示用的時間字串
    var displayTime: String {
        currentLocationInfo?.formattedTime ?? "--:--:--"
    }

    /// 顯示用的經緯度字串
    var displayLatLong: String {
        currentLocationInfo?.formattedLatLong ?? "-.------, -.------"
    }

    /// 顯示用的地址字串
    var displayAddress: String {
        currentLocationInfo?.displayAddress ?? Constants.Strings.Status.addressResolving
    }

    /// 是否可以拍照
    var canCapture: Bool {
        // 只需要相機準備就緒即可拍照
        // 位置資訊不是必須的，如果沒有位置會使用預設值
        return cameraStatus == .ready &&
               !isCaptureInProgress
    }

    // MARK: - Initialization

    init(
        cameraService: CameraServiceProtocol = CameraService(),
        locationService: LocationServiceProtocol = LocationService(),
        geocodingService: GeocodingServiceProtocol = GeocodingService(),
        photoService: PhotoServiceProtocol = PhotoService(),
        audioService: AudioServiceProtocol = AudioService()
    ) {
        self.cameraService = cameraService
        self.locationService = locationService
        self.geocodingService = geocodingService
        self.photoService = photoService
        self.audioService = audioService
    }

    // MARK: - Public Methods

    /// 啟動相機和位置服務
    func startServices() {
        print("🚀 啟動服務")
        startCamera()
        startLocation()
        print("✅ 服務啟動完成")
    }

    /// 停止相機和位置服務
    func stopServices() {
        stopCamera()
        stopLocation()
    }

    /// 拍照
    func capturePhoto() {
        // Debug 輸出
        print("📸 嘗試拍照")
        print("  - cameraStatus: \(cameraStatus)")
        print("  - locationStatus: \(locationStatus)")
        print("  - currentLocationInfo: \(currentLocationInfo != nil ? "有" : "無")")
        print("  - isCaptureInProgress: \(isCaptureInProgress)")
        print("  - canCapture: \(canCapture)")
        
        guard canCapture else {
            let message = "無法拍照：相機狀態=\(cameraStatus)"
            print("❌ \(message)")
            errorMessage = message
            return
        }
        
        isCaptureInProgress = true

        Task {
            do {
                print("✅ 開始拍照流程")
                print("  - 當前裝置方向: \(orientationName(deviceOrientation))")
                
                // 1. 播放快門聲
                print("  1️⃣ 播放快門聲")
                audioService.playShutterSound()

                // 2. 捕捉照片
                print("  2️⃣ 捕捉照片中...")
                let image = try await cameraService.capturePhoto()
                print("  ✅ 照片捕捉成功，尺寸: \(image.size)")

                // 3. 🔧 在拍照當下取得最新的時間戳記和位置資訊
                print("  3️⃣ 取得拍照當下的時間和位置...")
                let captureTimestamp = Date()  // 拍照當下的精確時間
                print("  ✅ 拍照時間: \(captureTimestamp.formattedDateTime())")
                
                // 使用當前位置資訊，但更新為拍照當下的時間戳記
                let locationInfo: LocationInfo
                if let currentInfo = currentLocationInfo {
                    // 有位置資訊：保留經緯度和地址，但更新時間戳記為拍照當下
                    locationInfo = LocationInfo(
                        latitude: currentInfo.latitude,
                        longitude: currentInfo.longitude,
                        address: currentInfo.address,
                        timestamp: captureTimestamp,  // 使用拍照當下的時間
                        accuracy: currentInfo.accuracy
                    )
                    print("  ✅ 使用 GPS 位置 + 拍照時間")
                } else {
                    // 沒有位置資訊：使用預設值，但時間戳記仍為拍照當下
                    locationInfo = LocationInfo(
                        latitude: 0.0,
                        longitude: 0.0,
                        address: "位置資訊無法取得",
                        timestamp: captureTimestamp,  // 使用拍照當下的時間
                        accuracy: -1.0
                    )
                    print("  ⚠️ 無 GPS 位置，使用預設值 + 拍照時間")
                }

                // 4. 添加浮水印（使用更新後的位置資訊，包含正確的拍照時間）
                print("  4️⃣ 添加浮水印...")
                let watermarkedImage = photoService.addWatermark(
                    to: image,
                    with: locationInfo,
                    deviceOrientation: deviceOrientation
                )
                print("  ✅ 浮水印添加成功")

                // 5. 儲存到相簿
                print("  5️⃣ 儲存到相簿...")
                try await photoService.saveToPhotoLibrary(watermarkedImage)
                print("  ✅ 照片儲存成功")

                // 6. 顯示成功提示
                print("  6️⃣ 顯示成功提示")
                showSuccessAlert = true
                audioService.playHapticFeedback()

                // 3 秒後自動隱藏成功提示
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                showSuccessAlert = false
                
                print("✅ 拍照流程完成")

            } catch {
                print("❌ 拍照失敗: \(error.localizedDescription)")
                errorMessage = "拍照失敗: \(error.localizedDescription)"
                audioService.playErrorSound()
            }

            isCaptureInProgress = false
        }
    }
    
    // MARK: - Helper Methods
    
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

    /// 請求所有必要權限
    func requestPermissions() {
        // 權限請求由各個 Service 內部處理
        startCamera()
        startLocation()
    }

    // MARK: - Private Methods - Camera

    private func startCamera() {
        // 設定相機狀態更新回調
        setupCameraStatusUpdates()
        
        // 啟動相機會話
        cameraService.startSession()
    }
    
    private func setupCameraStatusUpdates() {
        cameraService.onStatusChange = { [weak self] status in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                print("📷 相機狀態更新: \(status)")
                self.cameraStatus = status
            }
        }
    }

    private func stopCamera() {
        cameraService.stopSession()
    }

    // MARK: - Private Methods - Location

    private func startLocation() {
        // 設定位置更新回調
        setupLocationUpdates()

        // 開始位置更新
        locationService.startUpdatingLocation()

        // 更新狀態
        locationStatus = locationService.status
    }

    private func stopLocation() {
        locationService.stopUpdatingLocation()
    }

    private func setupLocationUpdates() {
        locationService.onLocationUpdate = { [weak self] locationInfo in
            Task { @MainActor [weak self] in
                guard let self = self else { return }

                // 更新位置資訊（但尚未包含地址）
                self.currentLocationInfo = locationInfo

                // 非同步取得地址
                await self.fetchAddress(for: locationInfo)
            }
        }
    }

    /// 取得地址資訊
    private func fetchAddress(for locationInfo: LocationInfo) async {
        do {
            let address = try await geocodingService.reverseGeocodeWithRetry(
                latitude: locationInfo.latitude,
                longitude: locationInfo.longitude,
                maxRetries: 3
            )

            // 更新 LocationInfo 包含地址
            let updatedLocationInfo = LocationInfo(
                latitude: locationInfo.latitude,
                longitude: locationInfo.longitude,
                address: address,
                timestamp: locationInfo.timestamp,
                accuracy: locationInfo.accuracy
            )

            self.currentLocationInfo = updatedLocationInfo

        } catch {
            // 地理編碼失敗，保持原本的 LocationInfo（地址為 nil）
            print("⚠️ 地理編碼失敗: \(error.localizedDescription)")
        }
    }

    /// 取得相機預覽層
    func getCameraPreviewLayer() -> AVCaptureVideoPreviewLayer {
        return cameraService.getPreviewLayer()
    }
}

// MARK: - Preview Helper

#if DEBUG
extension CameraViewModel {
    /// 用於 SwiftUI 預覽的模擬 ViewModel
    static var preview: CameraViewModel {
        let viewModel = CameraViewModel()
        viewModel.cameraStatus = .ready
        viewModel.locationStatus = .located
        viewModel.currentLocationInfo = .taipei101
        return viewModel
    }

    /// 用於測試錯誤狀態的 ViewModel
    static var errorPreview: CameraViewModel {
        let viewModel = CameraViewModel()
        viewModel.cameraStatus = .error("相機無法使用")
        viewModel.locationStatus = .error("無法取得位置")
        viewModel.errorMessage = "發生錯誤"
        return viewModel
    }
}
#endif
