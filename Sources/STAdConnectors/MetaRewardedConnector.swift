//
//  MetaRewardedConnector.swift
//  STAdConnectors
//

import FBAudienceNetwork
import STAdCore
import UIKit

public final class MetaRewardedConnector: NSObject, AdRewardedPresenting {

    // MARK: - Data

    private var rewardedAd: FBRewardedVideoAd?
    private let placementId: String
    private var isLoading: Bool = false
    private var onRewarded: (() -> Void)?
    private var onDismissed: (() -> Void)?
    private var didEarnReward: Bool = false

    // MARK: - Init

    public init(placementId: String) {
        self.placementId = placementId
        super.init()
    }

    deinit { }

    // MARK: - 광고 미리 로드

    public func preload() {
        guard !self.isLoading, self.rewardedAd == nil else { return }
        self.isLoading = true

        let ad = FBRewardedVideoAd(placementID: self.placementId)
        ad.delegate = self
        ad.load()
        self.rewardedAd = ad
    }

    // MARK: - 광고 표시

    public var isReady: Bool {
        return self.rewardedAd?.isAdValid ?? false
    }

    public func present(
        from viewController: UIViewController,
        onRewarded: @escaping () -> Void,
        onDismissed: @escaping () -> Void
    ) {
        guard let ad = self.rewardedAd, ad.isAdValid else {
            STAdLogger.warning("[Meta] 리워드 광고 미준비 - 스킵")
            onDismissed()
            return
        }

        self.onRewarded = onRewarded
        self.onDismissed = onDismissed
        self.didEarnReward = false

        ad.show(fromRootViewController: viewController)
    }
}

// MARK: - FBRewardedVideoAdDelegate

extension MetaRewardedConnector: FBRewardedVideoAdDelegate {

    public func rewardedVideoAdDidLoad(_ rewardedVideoAd: FBRewardedVideoAd) {
        self.isLoading = false
        STAdLogger.debug("[Meta] 리워드 광고 로드 완료")
    }

    public func rewardedVideoAd(_ rewardedVideoAd: FBRewardedVideoAd, didFailWithError error: Error) {
        self.isLoading = false
        self.rewardedAd = nil
        STAdLogger.error("[Meta] 리워드 광고 로드 실패: \(error.localizedDescription)")
    }

    public func rewardedVideoAdVideoComplete(_ rewardedVideoAd: FBRewardedVideoAd) {
        STAdLogger.debug("[Meta] 리워드 보상 수령")
        self.didEarnReward = true
        self.onRewarded?()
    }

    public func rewardedVideoAdDidClose(_ rewardedVideoAd: FBRewardedVideoAd) {
        STAdLogger.debug("[Meta] 리워드 광고 닫힘")
        self.rewardedAd = nil
        self.onDismissed?()
        self.onRewarded = nil
        self.onDismissed = nil

        self.preload()
    }

    public func rewardedVideoAdDidClick(_ rewardedVideoAd: FBRewardedVideoAd) {
        STAdLogger.debug("[Meta] 리워드 광고 클릭")
    }
}
