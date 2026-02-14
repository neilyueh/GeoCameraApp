//
//  LocationService.swift
//  GeoCameraApp
//
//  Created by Claude on 2026/02/14.
//

import CoreLocation
import Foundation

/// 位置服務協議
protocol LocationServiceProtocol {
    /// 開始位置更新
    func startUpdatingLocation()

    /// 停止位置更新
    func stopUpdatingLocation()

    /// 當前位置資訊
    var currentLocation: LocationInfo? { get }

    /// 位置狀態
    var status: LocationStatus { get }

    /// 位置更新回調
    var onLocationUpdate: ((LocationInfo) -> Void)? { get set }
}

/// 位置服務實作
class LocationService: NSObject, LocationServiceProtocol {
    // MARK: - Properties

    private let locationManager = CLLocationManager()

    private(set) var currentLocation: LocationInfo?
    private(set) var status: LocationStatus = .notAuthorized

    var onLocationUpdate: ((LocationInfo) -> Void)?

    // MARK: - Initialization

    override init() {
        super.init()
        setupLocationManager()
    }

    // MARK: - Public Methods

    func startUpdatingLocation() {
        // 檢查並請求權限
        let authStatus = locationManager.authorizationStatus

        switch authStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            status = .locating
            locationManager.startUpdatingLocation()

        case .notDetermined:
            status = .locating
            locationManager.requestWhenInUseAuthorization()

        case .denied, .restricted:
            status = .notAuthorized

        @unknown default:
            status = .error("未知的授權狀態")
        }
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    // MARK: - Private Methods

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = Constants.GPS.desiredAccuracy
        locationManager.distanceFilter = Constants.GPS.distanceFilter
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                        didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        // 檢查位置準確度（忽略準確度過低的位置）
        guard location.horizontalAccuracy >= 0 &&
              location.horizontalAccuracy <= 100 else {
            return
        }

        // 轉換為 LocationInfo
        let locationInfo = LocationInfo(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            address: nil, // 地址稍後由 GeocodingService 填入
            timestamp: location.timestamp,
            accuracy: location.horizontalAccuracy
        )

        // 更新狀態
        status = .located
        currentLocation = locationInfo

        // 觸發回調
        onLocationUpdate?(locationInfo)
    }

    func locationManager(_ manager: CLLocationManager,
                        didFailWithError error: Error) {
        status = .error(error.localizedDescription)

        // 記錄錯誤
        print("❌ 定位失敗: \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let authStatus = manager.authorizationStatus

        switch authStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            status = .locating
            locationManager.startUpdatingLocation()

        case .denied, .restricted:
            status = .notAuthorized

        case .notDetermined:
            status = .locating

        @unknown default:
            status = .error("未知的授權狀態")
        }
    }
}
