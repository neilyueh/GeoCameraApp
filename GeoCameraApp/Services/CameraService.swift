//
//  CameraService.swift
//  GeoCameraApp
//
//  Created by Claude on 2026/02/14.
//

import AVFoundation
import UIKit

/// 相機服務協議
protocol CameraServiceProtocol {
    /// 啟動相機會話
    func startSession()

    /// 停止相機會話
    func stopSession()

    /// 拍照
    /// - Returns: 捕捉的照片 UIImage
    func capturePhoto() async throws -> UIImage

    /// 取得預覽層
    /// - Returns: AVCaptureVideoPreviewLayer
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer

    /// 相機狀態
    var status: CameraStatus { get }
    
    /// 狀態更新回調
    var onStatusChange: ((CameraStatus) -> Void)? { get set }
}

/// 相機服務實作
class CameraService: NSObject, CameraServiceProtocol {
    // MARK: - Properties

    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    private(set) var status: CameraStatus = .configuring {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.onStatusChange?(self.status)
            }
        }
    }
    
    // 狀態更新回調
    var onStatusChange: ((CameraStatus) -> Void)?
    
    // 防止重複設定
    private var isConfigured = false
    private var isConfiguring = false

    // 用於等待拍照完成
    private var photoContinuation: CheckedContinuation<UIImage, Error>?

    // MARK: - Initialization

    override init() {
        super.init()
    }

    // MARK: - Public Methods

    func startSession() {
        print("🎬 startSession 被調用")
        
        // 防止重複啟動
        if session.isRunning {
            print("  ⚠️ Session 已在運行中，忽略")
            return
        }
        
        // 防止重複配置
        if isConfiguring {
            print("  ⚠️ Session 正在配置中，忽略")
            return
        }
        
        // 檢查相機權限
        checkCameraPermission { [weak self] authorized in
            guard let self = self else { return }

            if authorized {
                print("  ✅ 相機權限已授權")
                // 如果已經配置過，直接啟動；否則進行設定
                if self.isConfigured {
                    print("  ♻️ 重新啟動已配置的 session")
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.session.startRunning()
                        DispatchQueue.main.async {
                            self.status = .ready
                        }
                    }
                } else {
                    print("  🔧 首次配置 session")
                    self.setupCamera()
                }
            } else {
                print("  ❌ 相機權限未授權")
                self.status = .notAuthorized
            }
        }
    }

    func stopSession() {
        guard session.isRunning else {
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
        }
    }

    func capturePhoto() async throws -> UIImage {
        guard status == .ready else {
            throw NSError(domain: "CameraService", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "相機未就緒"])
        }

        status = .capturing

        return try await withCheckedThrowingContinuation { continuation in
            self.photoContinuation = continuation

            let settings = AVCapturePhotoSettings()
            settings.photoQualityPrioritization = Constants.Camera.photoQualityPrioritization

            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        if previewLayer == nil {
            // 在主執行緒創建 preview layer
            if Thread.isMainThread {
                previewLayer = AVCaptureVideoPreviewLayer(session: session)
                previewLayer?.videoGravity = .resizeAspectFill
            } else {
                DispatchQueue.main.sync {
                    previewLayer = AVCaptureVideoPreviewLayer(session: session)
                    previewLayer?.videoGravity = .resizeAspectFill
                }
            }
        }
        return previewLayer!
    }

    // MARK: - Private Methods

    private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }

    private func setupCamera() {
        print("  🔧 setupCamera 開始")
        
        // 標記為正在配置
        isConfiguring = true
        
        // 在背景執行緒進行相機設定
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            print("    🔧 開始配置 session")
            
            // 開始配置
            self.session.beginConfiguration()
            
            // 設定 session 品質
            self.session.sessionPreset = .photo

            // 取得後置鏡頭
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                        for: .video,
                                                        position: .back) else {
                print("    ❌ 無法取得相機裝置")
                DispatchQueue.main.async {
                    self.status = .error("無法取得相機裝置")
                    self.isConfiguring = false
                }
                self.session.commitConfiguration()
                return
            }

            do {
                // 建立輸入
                let input = try AVCaptureDeviceInput(device: camera)

                // 添加輸入
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                    print("    ✅ 成功添加相機輸入")
                } else {
                    print("    ❌ 無法添加相機輸入")
                    DispatchQueue.main.async {
                        self.status = .error("無法添加相機輸入")
                        self.isConfiguring = false
                    }
                    self.session.commitConfiguration()
                    return
                }

                // 添加輸出
                if self.session.canAddOutput(self.photoOutput) {
                    self.session.addOutput(self.photoOutput)
                    print("    ✅ 成功添加照片輸出")
                } else {
                    print("    ❌ 無法添加照片輸出")
                    DispatchQueue.main.async {
                        self.status = .error("無法添加照片輸出")
                        self.isConfiguring = false
                    }
                    self.session.commitConfiguration()
                    return
                }

                // 完成配置
                self.session.commitConfiguration()
                print("    ✅ Session 配置完成")
                
                // 標記為已配置
                self.isConfigured = true
                self.isConfiguring = false
                
                // 啟動 session
                print("    🚀 啟動 session")
                self.session.startRunning()

                DispatchQueue.main.async {
                    print("    ✅ Session 啟動成功，狀態設為 ready")
                    self.status = .ready
                }

            } catch {
                print("    ❌ 相機設定失敗: \(error.localizedDescription)")
                self.session.commitConfiguration()
                DispatchQueue.main.async {
                    self.status = .error("相機設定失敗: \(error.localizedDescription)")
                    self.isConfiguring = false
                }
            }
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                    didFinishProcessingPhoto photo: AVCapturePhoto,
                    error: Error?) {
        defer {
            status = .ready
        }

        if let error = error {
            photoContinuation?.resume(throwing: error)
            photoContinuation = nil
            return
        }

        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            let error = NSError(domain: "CameraService", code: 2,
                              userInfo: [NSLocalizedDescriptionKey: "無法處理照片資料"])
            photoContinuation?.resume(throwing: error)
            photoContinuation = nil
            return
        }

        photoContinuation?.resume(returning: image)
        photoContinuation = nil
    }
}
