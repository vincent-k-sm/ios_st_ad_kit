//
//  MetaInitializer.swift
//  STAdConnectors
//

import AppTrackingTransparency
import FBAudienceNetwork
import STAdCore

/// Meta Audience Network SDK 초기화 헬퍼
public final class MetaInitializer {

    // MARK: - Singleton

    public static let shared = MetaInitializer()

    // MARK: - Data

    private(set) public var isInitialized: Bool = false

    // MARK: - Init

    private init() { }

    deinit { }

    // MARK: - SDK 초기화

    public func initialize(testMode: Bool) {
        if testMode {
            FBAdSettings.addTestDevice(FBAdSettings.testDeviceHash())
            STAdLogger.debug("[MetaAds] 테스트 모드 활성화")
        }

        // iOS 14+ ATE 플래그 설정 (Meta 수익화 필수)
        if #available(iOS 14, *) {
            let status = ATTrackingManager.trackingAuthorizationStatus
            FBAdSettings.setAdvertiserTrackingEnabled(status == .authorized)
            STAdLogger.debug("[MetaAds] ATE 플래그 설정: \(status == .authorized)")
        }
        else {
            FBAdSettings.setAdvertiserTrackingEnabled(true)
        }

        self.isInitialized = true
        STAdLogger.debug("[MetaAds] SDK 설정 완료")
    }
}
