# 時間戳記修復摘要

## 問題描述
照片的日期與時間是在 App 啟動或 GPS 定位時生成的，而不是在拍照當下生成。這導致如果使用者開啟 App 後過了一段時間才拍照，照片記錄的時間會比實際拍攝時間早。

## 根本原因
- **原始實作**：`LocationInfo` 的 `timestamp` 來自 `CLLocation.timestamp`（GPS 定位的時間）
- **問題**：GPS 會持續更新位置，但如果長時間沒有移動，GPS timestamp 可能不會更新，導致拍照時使用的是舊的時間戳記

## 修復方案

### 1. CameraViewModel.swift 的修改
在 `capturePhoto()` 方法中：

**修改前：**
```swift
// 如果沒有位置資訊，使用預設值
let locationInfo = currentLocationInfo ?? LocationInfo.unknown
```

**修改後：**
```swift
// 在拍照當下取得最新的時間戳記
let captureTimestamp = Date()  // 拍照當下的精確時間

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
} else {
    // 沒有位置資訊：使用預設值，但時間戳記仍為拍照當下
    locationInfo = LocationInfo(
        latitude: 0.0,
        longitude: 0.0,
        address: "位置資訊無法取得",
        timestamp: captureTimestamp,  // 使用拍照當下的時間
        accuracy: -1.0
    )
}
```

### 2. 時間格式確認
已驗證時間格式符合要求（`YYYY/MM/DD HH:MM:SS`）：

- **日期格式**：`yyyy/MM/dd`（例如：2026/02/14）
- **時間格式**：`HH:mm:ss`（24小時制，例如：14:30:25）
- **完整格式**：`2026/02/14 14:30:25`

相關檔案：
- `LocationInfo.swift` - `formattedDate` 和 `formattedTime` 計算屬性
- `Date+Format.swift` - `formattedDate()` 和 `formattedTime()` 擴充方法

## 執行流程（修復後）

1. 使用者按下拍照按鈕
2. **立即取得當前時間** `let captureTimestamp = Date()`
3. 取得當前 GPS 位置（經緯度、地址）
4. **建立新的 LocationInfo，使用拍照當下的時間戳記**
5. 將時間戳記格式化為 `YYYY/MM/DD HH:MM:SS` 格式
6. 將格式化後的時間添加到照片浮水印
7. 儲存照片到相簿

## 優點

✅ **準確性**：時間戳記現在精確記錄拍照的瞬間
✅ **獨立性**：拍照時間不再依賴 GPS 更新頻率
✅ **一致性**：即使 GPS 無法定位，時間戳記仍然準確
✅ **格式標準**：嚴格遵守 `YYYY/MM/DD HH:MM:SS` 格式

## 測試建議

1. **基本測試**：
   - 開啟 App，立即拍照 → 檢查時間是否正確
   - 開啟 App，等待 5 分鐘後拍照 → 檢查時間是否為拍照當下（非 5 分鐘前）

2. **邊界測試**：
   - 在 GPS 無法定位時拍照 → 檢查時間是否仍然正確
   - 在飛航模式下拍照 → 檢查時間是否仍然正確
   - 連續拍多張照片 → 檢查每張照片的時間是否依序遞增

3. **格式測試**：
   - 檢查日期格式：`2026/02/15`（年4碼/月2碼/日2碼）
   - 檢查時間格式：`14:30:05`（時2碼:分2碼:秒2碼，24小時制）

## 變更檔案清單

- ✅ `CameraViewModel.swift` - 修改 `capturePhoto()` 方法
- ✅ `LocationInfo.swift` - 更新註釋說明
- ℹ️ `Date+Format.swift` - 無需修改（格式已正確）
- ℹ️ `PhotoService.swift` - 無需修改（使用傳入的 LocationInfo）

## 注意事項

- GPS 位置（經緯度、地址）仍然來自 `LocationService` 的持續更新
- 只有**時間戳記**在拍照當下重新生成
- 這確保了位置資訊的準確性，同時也確保了時間的準確性
