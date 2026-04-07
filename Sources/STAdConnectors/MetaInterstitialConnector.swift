//
//  MetaInterstitialConnector.swift
//  STAdConnectors
//

import FBAudienceNetwork
import STAdCore
import UIKit

public final class MetaInterstitialConnector: NSObject, AdInterstitialPresenting {

    // MARK: - Data

    private var interstitialAd: FBInterstitialAd?
    private let placementId: String
    private var isLoading: Bool = false
    private var onDismissed: (() -> Void)?

    // MARK: - Init

    public init(placementId: String) {
        self.placementId = placementId
        super.init()
    }

    deinit { }

    // MARK: - 광고 미리 로드

    public func preload() {
        guard !self.isLoading, self.interstitialAd == nil else { return }
        self.isLoading = true

        let ad = FBInterstitialAd(placementID: self.placementId)
        ad.delegate = self
        ad.load()
        self.interstitialAd = ad
    }

    // MARK: - 광고 표시

    public var isReady: Bool {
        return self.interstitialAd?.isAdValid ?? false
    }

    public func present(from viewController: UIViewController, completion: @escaping () -> Void) {
        guard let ad = self.interstitialAd, ad.isAdValid else {
            STAdLogger.warning("[Meta] 인터스티셜 미준비 - 스킵")
            completion()
            return
        }

        self.onDismissed = completion
        ad.show(fromRootViewController: viewController)
    }
}

// MARK: - FBInterstitialAdDelegate

extension MetaInterstitialConnector: FBInterstitialAdDelegate {

    public func interstitialAdDidLoad(_ interstitialAd: FBInterstitialAd) {
        self.isLoading = false
        STAdLogger.debug("[Meta] 인터스티셜 로드 완료")
    }

    public func interstitialAd(_ interstitialAd: FBInterstitialAd, didFailWithError error: Error) {
        self.isLoading = false
        self.interstitialAd = nil
        STAdLogger.error("[Meta] 인터스티셜 로드 실패: \(error.localizedDescription)")
    }

    public func interstitialAdDidClose(_ interstitialAd: FBInterstitialAd) {
        STAdLogger.debug("[Meta] 인터스티셜 닫힘")
        self.interstitialAd = nil
        self.onDismissed?()
        self.onDismissed = nil

        self.preload()
    }

    public func interstitialAdDidClick(_ interstitialAd: FBInterstitialAd) {
        STAdLogger.debug("[Meta] 인터스티셜 클릭")
    }
}
