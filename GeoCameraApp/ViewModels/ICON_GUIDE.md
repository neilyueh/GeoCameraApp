# GeoCameraApp Icon 生成指南

## 🎨 Icon 設計說明

這個 App Icon 的設計元素包括：

1. **藍色漸層背景** - 代表天空和地球
2. **白色相機鏡頭** - 主要功能：拍照
3. **紅色快門按鈕** - 操作提示
4. **白色 GPS 定位標記** - 地理資訊功能
5. **橙色定位點** - 強調位置追蹤
6. **"GEO" 文字** - 品牌識別

## 📦 使用方法

### 方法一：使用 IconGeneratorView（推薦）

1. 在 Xcode 中打開 `IconGeneratorView.swift`
2. 點擊右上角的 Resume 按鈕（▶️）啟動 Preview
3. 在 Preview 中點擊「預覽 Icon」查看效果
4. 點擊「生成所有尺寸」創建所有圖標
5. 打開 iPhone/iPad 的「檔案」App
6. 前往「我的 iPhone/iPad」→「GeoCameraApp」→「Documents」→「GeoCameraIcons」
7. 選擇所有 PNG 檔案，用 AirDrop 傳到 Mac
8. 在 Xcode 中打開 `Assets.xcassets` → `AppIcon`
9. 將圖標拖入對應的位置

### 方法二：在程式碼中調用

在任何 ViewController 或 SwiftUI View 中：

```swift
// 生成並保存所有尺寸
IconGenerator.generateAllIcons()

// 或只生成單一尺寸
let icon = IconGenerator.generateAppIcon(size: CGSize(width: 1024, height: 1024))
```

### 方法三：添加臨時按鈕到 ContentView

在 `ContentView.swift` 中添加（僅用於開發）：

```swift
.toolbar {
    #if DEBUG
    ToolbarItem(placement: .navigationBarTrailing) {
        Button("生成 Icon") {
            IconGenerator.generateAllIcons()
        }
    }
    #endif
}
```

## 📱 生成的 Icon 尺寸列表

| 名稱 | 尺寸 | 用途 |
|------|------|------|
| Icon-20@2x | 40x40 | iPad 通知 |
| Icon-20@3x | 60x60 | iPhone 通知 |
| Icon-29@2x | 58x58 | iPhone 設定 |
| Icon-29@3x | 87x87 | iPhone 設定 @3x |
| Icon-40@2x | 80x80 | iPhone Spotlight |
| Icon-40@3x | 120x120 | iPhone Spotlight @3x |
| Icon-60@2x | 120x120 | iPhone App |
| Icon-60@3x | 180x180 | iPhone App @3x |
| Icon-1024 | 1024x1024 | App Store |

## 🎯 在 Xcode 中設置 App Icon

1. 打開 Xcode 專案
2. 在左側導航欄選擇 `Assets.xcassets`
3. 點擊 `AppIcon`
4. 將生成的 PNG 檔案拖入對應的位置：
   - 20pt: Icon-20@2x.png 和 Icon-20@3x.png
   - 29pt: Icon-29@2x.png 和 Icon-29@3x.png
   - 40pt: Icon-40@2x.png 和 Icon-40@3x.png
   - 60pt: Icon-60@2x.png 和 Icon-60@3x.png
   - 1024pt: Icon-1024.png

5. 或者直接在 Xcode 中：
   - 選擇 AppIcon
   - 點擊右側的屬性檢查器
   - 選擇 "Single Size"
   - 只需拖入 Icon-1024.png
   - Xcode 會自動生成其他尺寸

## 🎨 自訂 Icon 設計

如果您想修改 Icon 的設計，請編輯 `IconGenerator.swift` 中的 `generateAppIcon` 方法：

```swift
// 修改背景顏色
let colors = [
    UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0).cgColor, // 改這裡
    UIColor(red: 0.1, green: 0.2, blue: 0.5, alpha: 1.0).cgColor  // 和這裡
]

// 修改文字
let text = "GEO" as NSString  // 改成您想要的文字

// 調整元素位置和大小
let cameraSize = size.width * 0.5  // 相機大小
let shutterSize = size.width * 0.12  // 快門按鈕大小
```

## 🐛 常見問題

### Q: 找不到生成的檔案？
A: 檔案保存在 App 的 Documents 目錄。使用「檔案」App 或 Xcode 的 Window → Devices and Simulators → 選擇您的設備 → 下載容器來存取。

### Q: 圖標在 Xcode 中不顯示？
A: 確保檔案格式為 PNG，並且尺寸正確。可以使用 Preview 或其他圖像編輯器檢查。

### Q: 想要不同的設計？
A: 修改 `IconGenerator.swift` 中的繪製代碼，或使用專業設計工具（如 Sketch, Figma）創建，然後匯入。

### Q: 可以使用照片或圖片嗎？
A: 可以！將圖片拖入 Assets.xcassets/AppIcon 即可。但程式生成的好處是：
   - 完全自訂
   - 向量圖形（任何尺寸都清晰）
   - 可程式化修改
   - 不需要設計軟體

## 📚 延伸閱讀

- [Apple Human Interface Guidelines - App Icons](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [iOS App Icon 設計規範](https://developer.apple.com/design/human-interface-guidelines/foundations/app-icons)

## 🎉 完成！

現在您的 App 就有一個專業的 Icon 了！

如果您想要更精緻的設計，建議使用專業設計工具：
- SF Symbols (Apple 官方)
- Figma (免費)
- Sketch (付費)
- Adobe Illustrator (付費)
