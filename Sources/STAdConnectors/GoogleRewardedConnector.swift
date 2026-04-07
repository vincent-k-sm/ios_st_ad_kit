//
//  GoogleRewardedConnector.swift
//  STAdConnectors
//

import GoogleMobileAds
import STAdCore
import UIKit

public final class GoogleRewardedConnector: NSObject, AdRewardedPresenting {

    // MARK: - Data

    private var rewardedInterstitialAd: GADRewardedInterstitialAd?
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
        guard !self.isLoading, self.rewardedInterstitialAd == nil else { return }
        self.isLoading = true

        GADRewardedInterstitialAd.load(
            withAdUnitID: self.adUnitId,
            request: GADRequest(),
            completionHandler: { [weak self] ad, error in
                guard let self = self else { return }
                self.isLoading = false

                if let error = error {
                    STAdLogger.error("[Google] 리워드 전면 광고 로드 실패: \(error.localizedDescription)")
                    return
                }

                self.rewardedInterstitialAd = ad
                self.rewardedInterstitialAd?.fullScreenContentDelegate = self
                STAdLogger.debug("[Google] 리워드 전면 광고 로드 완료")
            }
        )
    }

    // MARK: - 광고 표시

    public var isReady: Bool {
        return self.rewardedInterstitialAd != nil
    }

    public func present(
        from viewController: UIViewController,
        onRewarded: @escaping () -> Void,
        onDismissed: @escaping () -> Void
    ) {
        guard let ad = self.rewardedInterstitialAd else {
            STAdLogger.warning("[Google] 리워드 전면 광고 미준비 - 스킵")
            onDismissed()
            return
        }

        self.onDismissed = onDismissed

        ad.present(fromRootViewController: viewController, userDidEarnRewardHandler: {
            STAdLogger.debug("[Google] 리워드 보상 수령")
            onRewarded()
        })
    }
}

// MARK: - GADFullScreenContentDelegate

extension GoogleRewardedConnector: GADFullScreenContentDelegate {

    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        STAdLogger.debug("[Google] 리워드 전면 광고 닫힘")
        self.rewardedInterstitialAd = nil
        self.onDismissed?()
        self.onDismissed = nil

        self.preload()
    }

    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        STAdLogger.error("[Google] 리워드 전면 광고 표시 실패: \(error.localizedDescription)")
        self.rewardedInterstitialAd = nil
        self.onDismissed?()
        self.onDismissed = nil

        self.preload()
    }
}
