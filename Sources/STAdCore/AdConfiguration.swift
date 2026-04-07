//
//  AdConfiguration.swift
//  STAdCore
//

import Foundation

public struct AdConfiguration {

    // MARK: - AdMob Ad Unit IDs

    public let bannerAdUnitId: String
    public let interstitialAdUnitId: String
    public let rewardedInterstitialAdUnitId: String

    // MARK: - Meta Audience Network Placement IDs

    public let metaBannerPlacementId: String
    public let metaInterstitialPlacementId: String
    public let metaRewardedPlacementId: String

    // MARK: - 인터스티셜 정책

    /// 인터스티셜 노출 간격 (곡 N개마다)
    public let interstitialFrequency: Int

    /// 앱 시작 후 첫 인터스티셜까지 유예 곡 수
    public let interstitialGracePeriod: Int

    // MARK: - Init

    public init(
        bannerAdUnitId: String,
        interstitialAdUnitId: String,
        rewardedInterstitialAdUnitId: String,
        metaBannerPlacementId: String = "",
        metaInterstitialPlacementId: String = "",
        metaRewardedPlacementId: String = "",
        interstitialFrequency: Int = 3,
        interstitialGracePeriod: Int = 2
    ) {
        self.bannerAdUnitId = bannerAdUnitId
        self.interstitialAdUnitId = interstitialAdUnitId
        self.rewardedInterstitialAdUnitId = rewardedInterstitialAdUnitId
        self.metaBannerPlacementId = metaBannerPlacementId
        self.metaInterstitialPlacementId = metaInterstitialPlacementId
        self.metaRewardedPlacementId = metaRewardedPlacementId
        self.interstitialFrequency = interstitialFrequency
        self.interstitialGracePeriod = interstitialGracePeriod
    }

    // MARK: - Meta 설정 여부

    public var hasMetaConfig: Bool {
        return !self.metaBannerPlacementId.isEmpty
    }
}
