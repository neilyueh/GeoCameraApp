//
//  GeocodingService.swift
//  GeoCameraApp
//
//  Created by Claude on 2026/02/14.
//

import CoreLocation
import Foundation

/// 地理編碼服務協議
protocol GeocodingServiceProtocol {
    /// 反向地理編碼（經緯度 → 地址）
    /// - Parameters:
    ///   - latitude: 緯度
    ///   - longitude: 經度
    /// - Returns: 格式化的地址字串
    func reverseGeocode(latitude: Double, longitude: Double) async throws -> String
    
    /// 帶重試機制的反向地理編碼
    /// - Parameters:
    ///   - latitude: 緯度
    ///   - longitude: 經度
    ///   - maxRetries: 最大重試次數（預設 3 次）
    /// - Returns: 格式化的地址字串
    func reverseGeocodeWithRetry(
        latitude: Double,
        longitude: Double,
        maxRetries: Int
    ) async throws -> String
}

/// 地理編碼服務實作
class GeocodingService: GeocodingServiceProtocol {
    // MARK: - Properties

    private let geocoder = CLGeocoder()

    // 地址快取（避免重複請求）
    private var addressCache: [String: String] = [:]

    // MARK: - Public Methods

    func reverseGeocode(latitude: Double, longitude: Double) async throws -> String {
        // 檢查快取
        let cacheKey = String(format: "%.4f,%.4f", latitude, longitude)
        if let cachedAddress = addressCache[cacheKey] {
            return cachedAddress
        }

        // 執行反向地理編碼
        let location = CLLocation(latitude: latitude, longitude: longitude)

        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)

            guard let placemark = placemarks.first else {
                throw NSError(domain: "GeocodingService", code: 1,
                            userInfo: [NSLocalizedDescriptionKey: "無法取得地址資訊"])
            }

            // 格式化地址
            let address = formatAddress(from: placemark)

            // 儲存到快取
            addressCache[cacheKey] = address

            return address

        } catch {
            // 清理快取（避免快取錯誤結果）
            addressCache.removeValue(forKey: cacheKey)
            throw error
        }
    }

    // MARK: - Private Methods

    /// 格式化地址為「縣市 + 區域 + 街道」格式
    private func formatAddress(from placemark: CLPlacemark) -> String {
        var components: [String] = []

        // 縣市（administrativeArea）
        if let city = placemark.administrativeArea {
            components.append(city)
        }

        // 區域（locality 或 subLocality）
        if let district = placemark.locality ?? placemark.subLocality {
            components.append(district)
        }

        // 街道（thoroughfare）
        if let street = placemark.thoroughfare {
            components.append(street)
        }

        // 門牌號碼（subThoroughfare）
        if let number = placemark.subThoroughfare {
            components.append(number)
        }

        // 如果沒有任何地址資訊，返回完整的格式化地址
        if components.isEmpty {
            if let name = placemark.name {
                return name
            }
            return "未知地址"
        }

        return components.joined(separator: "")
    }

    /// 清除地址快取
    func clearCache() {
        addressCache.removeAll()
    }
}

// MARK: - Retry Logic Extension

extension GeocodingService {
    /// 帶重試機制的反向地理編碼
    /// - Parameters:
    ///   - latitude: 緯度
    ///   - longitude: 經度
    ///   - maxRetries: 最大重試次數（預設 3 次）
    /// - Returns: 格式化的地址字串
    func reverseGeocodeWithRetry(
        latitude: Double,
        longitude: Double,
        maxRetries: Int = 3
    ) async throws -> String {
        var lastError: Error?

        for attempt in 0..<maxRetries {
            do {
                return try await reverseGeocode(latitude: latitude, longitude: longitude)
            } catch {
                lastError = error

                // 如果不是最後一次嘗試，等待後重試
                if attempt < maxRetries - 1 {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 等待 1 秒
                }
            }
        }

        // 所有重試都失敗，拋出錯誤
        throw lastError ?? NSError(
            domain: "GeocodingService",
            code: 2,
            userInfo: [NSLocalizedDescriptionKey: "地理編碼失敗"]
        )
    }
}
