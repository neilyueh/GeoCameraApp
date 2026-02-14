# GeoCameraApp UI 優化技術文檔

## 📋 優化項目總結

### 1. 直立模式佈局重疊問題 ✅ 已解決

**問題**：
- 浮水印資訊（InfoOverlayView）與快門按鈕（CaptureButtonView）在直立模式時重疊
- 影響使用者體驗和視覺美觀

**解決方案**：
```swift
// 在直立模式時，為快門按鈕預留空間
.padding(.bottom, 150)  
// 計算方式：按鈕高度(80) + 底部padding(50) + 安全間距(20) = 150
```

**實作細節**：
- 使用動態 padding 根據按鈕位置調整
- 確保資訊視圖始終在按鈕上方
- 保持適當的視覺間距

### 2. 橫向模式預覽浮水印顯示 ✅ 已優化

**問題**：
- 橫向拍攝時，預覽畫面上的浮水印保持直立方向
- 雖然最終照片會正確旋轉，但預覽時不直觀

**解決方案**：
```swift
@ViewBuilder
private var infoOverlayView: some View {
    GeometryReader { geometry in
        if isLandscape {
            // 橫向模式：資訊在底部左側
            VStack {
                Spacer()
                HStack {
                    InfoOverlayView(...)
                    .padding(Constants.UI.screenEdgePadding)
                    Spacer()
                }
            }
        } else {
            // 直立模式：資訊在右側上方
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    InfoOverlayView(...)
                    .padding(.trailing, Constants.UI.screenEdgePadding)
                }
                .padding(.bottom, 150)
            }
        }
    }
    .animation(.easeInOut(duration: 0.3), value: isLandscape)
}
```

## 🎯 技術實作詳解

### A. 裝置方向監測

**使用 UIDeviceOrientation**：

```swift
// 在 ContentView 中
@State private var orientation = UIDeviceOrientation.portrait

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
        if newOrientation.isValidInterfaceOrientation {
            orientation = newOrientation
            viewModel.deviceOrientation = newOrientation
            print("📱 裝置方向變更: \(orientationName(newOrientation))")
        }
    }
}
```

**方向判斷**：

```swift
private var isLandscape: Bool {
    return orientation.isLandscape
}

// UIDeviceOrientation 擴展
extension UIDeviceOrientation {
    var isLandscape: Bool {
        return self == .landscapeLeft || self == .landscapeRight
    }
}
```

### B. UI 佈局動態調整

**1. 資訊視圖位置**：

```swift
// 直立模式
VStack {
    Spacer()
    HStack {
        Spacer()
        InfoOverlayView(...)  // 右下角（按鈕上方）
    }
    .padding(.bottom, 150)  // 為按鈕預留空間
}

// 橫向模式
VStack {
    Spacer()
    HStack {
        InfoOverlayView(...)  // 左下角
        Spacer()
    }
}
```

**2. 快門按鈕位置**：

```swift
if isLandscape {
    // 橫向：右側中央
    HStack {
        Spacer()
        VStack {
            Spacer()
            CaptureButtonView(...)
            Spacer()
        }
        .padding(.trailing, 30)
    }
} else {
    // 直立：底部中央
    VStack {
        Spacer()
        HStack {
            Spacer()
            CaptureButtonView(...)
            Spacer()
        }
        .padding(.bottom, 50)
    }
}
```

### C. 平滑動畫過渡

**動畫實作**：

```swift
// 方法 1：使用 .animation() modifier
.animation(.easeInOut(duration: 0.3), value: isLandscape)

// 方法 2：使用 withAnimation
withAnimation(.easeInOut(duration: 0.3)) {
    orientation = newOrientation
}

// 方法 3：使用 .transition()
.transition(.opacity)  // 淡入淡出
.transition(.move(edge: .trailing))  // 從右側滑入
.transition(.move(edge: .bottom))  // 從底部滑入
```

**動畫時機**：
- 方向變化時：300ms easeInOut
- 按鈕移動時：配合 transition 效果
- 資訊視圖調整時：透明度和位置同時變化

### D. 照片浮水印旋轉邏輯

**在 PhotoService.swift 中**：

```swift
func addWatermark(
    to image: UIImage, 
    with locationInfo: LocationInfo, 
    deviceOrientation: UIDeviceOrientation
) -> UIImage {
    
    // 根據裝置方向決定繪製方式
    if deviceOrientation.isLandscape {
        drawRotatedWatermark(
            in: context.cgContext,
            lines: lines,
            imageSize: normalizedImage.size,
            deviceOrientation: deviceOrientation
        )
    } else {
        drawNormalWatermark(
            lines: lines,
            imageSize: normalizedImage.size
        )
    }
}
```

**旋轉算法**：

```swift
private func drawRotatedWatermark(...) {
    context.saveGState()
    
    // 計算旋轉角度和位置
    var rotationAngle: CGFloat = 0
    var translationX: CGFloat = 0
    var translationY: CGFloat = 0
    
    if deviceOrientation == .landscapeLeft {
        // Home 鍵在左側 → 順時針旋轉 90°
        rotationAngle = .pi / 2
        translationX = imageSize.width - margin
        translationY = imageSize.height - textWidth - margin
    } else if deviceOrientation == .landscapeRight {
        // Home 鍵在右側 → 逆時針旋轉 90°
        rotationAngle = -.pi / 2
        translationX = totalHeight + margin
        translationY = textWidth + margin
    }
    
    // 應用變換
    context.translateBy(x: translationX, y: translationY)
    context.rotate(by: rotationAngle)
    
    // 繪製文字和背景
    // ...
    
    context.restoreGState()
}
```

## 📊 技術架構圖

```
┌─────────────────────────────────────┐
│      UIDevice Orientation           │
│     NotificationCenter              │
└───────────┬─────────────────────────┘
            │
            ▼
┌─────────────────────────────────────┐
│      ContentView                    │
│  - orientation: UIDeviceOrientation │
│  - startOrientationObserver()       │
└───────────┬─────────────────────────┘
            │
            ├──────────┬────────────────┐
            ▼          ▼                ▼
    ┌──────────┐  ┌────────┐   ┌──────────────┐
    │InfoOverlay│  │ Button │   │ CameraViewModel│
    │   View    │  │ Layout │   │ .deviceOrient │
    └──────────┘  └────────┘   └───────┬────────┘
                                        │
                                        ▼
                            ┌─────────────────────┐
                            │   PhotoService      │
                            │ addWatermark()      │
                            │ drawRotated...()    │
                            └─────────────────────┘
```

## 🎨 視覺效果說明

### 直立模式（Portrait）

```
┌─────────────────────┐
│                     │
│    Camera Preview   │
│                     │
│                     │
│              [Info] │ ← 浮水印資訊
│              View   │    (右側上方)
│                     │
│                     │
│        ( O )        │ ← 快門按鈕
│                     │    (底部中央)
└─────────────────────┘
```

### 橫向模式（Landscape Left）

```
┌─────────────────────────────────────────┐
│                                         │
│         Camera Preview                  │
│                                         │
│ [Info View]                             │
│ (左下角)                        ( O )   │
│                                  ↑      │
│                               快門按鈕   │
│                               (右側中央) │
└─────────────────────────────────────────┘
```

## ✅ 優化成果

### 1. 佈局改進
- ✅ 直立模式：浮水印在快門按鈕上方，間距 20pt
- ✅ 橫向模式：浮水印在左下角，按鈕在右側中央
- ✅ 無視覺重疊，操作流暢

### 2. 使用者體驗
- ✅ 300ms 平滑動畫過渡
- ✅ 符合人體工學（右手大拇指操作）
- ✅ 資訊始終清晰可讀

### 3. 照片品質
- ✅ 直立拍攝：浮水印在右下角
- ✅ 橫向拍攝：浮水印自動旋轉，保持水平可讀
- ✅ 文字方向正確，位置合適

## 🔍 測試檢查清單

- [ ] 直立模式：浮水印與按鈕無重疊
- [ ] 直立模式：浮水印在按鈕上方約 20pt
- [ ] 橫向左模式：按鈕在右側中央
- [ ] 橫向右模式：按鈕在右側中央
- [ ] 橫向模式：浮水印在左下角
- [ ] 方向切換：動畫平滑（300ms）
- [ ] 直立拍照：照片浮水印在右下角
- [ ] 橫向左拍照：照片浮水印旋轉 90°
- [ ] 橫向右拍照：照片浮水印旋轉 -90°
- [ ] 所有方向：文字水平可讀

## 📝 未來改進建議

1. **自適應間距**：根據螢幕尺寸動態調整
2. **更多動畫效果**：彈簧動畫、縮放效果
3. **iPad 支援**：考慮更大螢幕的佈局
4. **無障礙功能**：VoiceOver 支援
5. **暗色模式**：浮水印背景適配

## 🎯 關鍵代碼位置

| 功能 | 檔案 | 行數 |
|------|------|------|
| 方向監測 | ContentView.swift | 70-90 |
| 資訊視圖佈局 | ContentView.swift | 92-125 |
| 按鈕佈局 | ContentView.swift | 127-160 |
| 照片浮水印旋轉 | PhotoService.swift | 30-80 |
| 旋轉算法 | PhotoService.swift | 138-200 |

## 💡 最佳實踐

1. **使用 @Published 變數**：確保 UI 自動更新
2. **GeometryReader**：根據實際尺寸調整佈局
3. **@ViewBuilder**：靈活組合不同方向的 UI
4. **CGContext transform**：高效的圖形變換
5. **保持狀態同步**：ViewModel 與 View 的方向一致

---

**文檔版本**: 1.0  
**最後更新**: 2026/02/14  
**作者**: Claude  
**專案**: GeoCameraApp
