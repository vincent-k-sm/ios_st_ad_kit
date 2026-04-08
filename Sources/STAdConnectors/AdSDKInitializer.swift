//
//  AdSDKInitializer.swift
//  STAdConnectors
//
//  Google Mobile Ads SDK 초기화 헬퍼.
//  AdMobKit 래퍼에서 GoogleMobileAds를 직접 import하지 않도록 캡슐화.
//

import GoogleMobileAds

public final class AdSDKInitializer {

    private init() { }

    /// Google Mobile Ads SDK를 초기화한다.
    /// - Parameters:
    ///   - isTestMode: true이면 시뮬레이터를 테스트 기기로 등록
    ///   - completion: SDK 준비 완료 콜백
    public static func start(isTestMode: Bool = false, completion: @escaping () -> Void) {
        if isTestMode {
            GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [
                GADSimulatorID
            ]
        }
        GADMobileAds.sharedInstance().start { _ in
            completion()
        }
    }
}
