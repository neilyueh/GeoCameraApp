//
//  CameraPreviewView.swift
//  GeoCameraApp
//
//  Created by Claude on 2026/02/14.
//

import SwiftUI
import AVFoundation

/// 相機預覽視圖的容器
class PreviewUIView: UIView {
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 在 layoutSubviews 中更新 layer frame，這是更新 sublayer frame 的正確時機
        previewLayer?.frame = bounds
    }
}

/// 相機預覽視圖
/// 使用 UIViewRepresentable 包裝 AVCaptureVideoPreviewLayer
struct CameraPreviewView: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer

    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView(frame: .zero)
        
        // 設定預覽層
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        view.previewLayer = previewLayer
        
        return view
    }

    func updateUIView(_ uiView: PreviewUIView, context: Context) {
        // layoutSubviews 會自動處理 frame 更新
    }
}

// MARK: - Preview

#if DEBUG
struct CameraPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        let session = AVCaptureSession()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)

        CameraPreviewView(previewLayer: previewLayer)
            .ignoresSafeArea()
    }
}
#endif
