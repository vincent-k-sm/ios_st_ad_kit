//
//  GoogleInterstitialConnector.swift
//  STAdConnectors
//

import GoogleMobileAds
import STAdCore
import UIKit

public final class GoogleInterstitialConnector: NSObject, AdInterstitialPresenting {

    // MARK: - Data

    private var interstitialAd: GADInterstitialAd?
    private let adUnitId: String
    private var isLoading: Bool = false
    private var onDismissed: (() -> Void)?

    // MARK: - Init

    public init(adUnitId: String) {
        self.adUnitId = adUnitId
        super.init()
    }

    deinit { }

    // MARK: - 광고 미리 로드

    public func preload() {
        guard !self.isLoading, self.interstitialAd == nil else { return }
        self.isLoading = true

        GADInterstitialAd.load(
            withAdUnitID: self.adUnitId,
            request: GADRequest(),
            completionHandler: { [weak self] ad, error in
                guard let self = self else { return }
                self.isLoading = false

                if let error = error {
                    STAdLogger.error("[Google] 인터스티셜 로드 실패: \(error.localizedDescription)")
                    return
                }

                self.interstitialAd = ad
                self.interstitialAd?.fullScreenContentDelegate = self
                STAdLogger.debug("[Google] 인터스티셜 로드 완료")
            }
        )
    }

    // MARK: - 광고 표시

    public var isReady: Bool {
        return self.interstitialAd != nil
    }

    public func present(from viewController: UIViewController, completion: @escaping () -> Void) {
        guard let ad = self.interstitialAd else {
            STAdLogger.warning("[Google] 인터스티셜 미준비 - 스킵")
            completion()
            return
        }

        self.onDismissed = completion
        ad.present(fromRootViewController: viewController)
    }
}

// MARK: - GADFullScreenContentDelegate

extension GoogleInterstitialConnector: GADFullScreenContentDelegate {

    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        STAdLogger.debug("[Google] 인터스티셜 닫힘")
        self.interstitialAd = nil
        self.onDismissed?()
        self.onDismissed = nil

        self.preload()
    }

    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        STAdLogger.error("[Google] 인터스티셜 표시 실패: \(error.localizedDescription)")
        self.interstitialAd = nil
        self.onDismissed?()
        self.onDismissed = nil

        self.preload()
    }
}
