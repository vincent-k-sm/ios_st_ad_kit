//
//  GoogleBannerConnector.swift
//  STAdConnectors
//

import GoogleMobileAds
import STAdCore
import UIKit

public final class GoogleBannerConnector: NSObject, BannerAdLoading {

    // MARK: - BannerAdLoading

    public var bannerView: UIView? {
        return self.googleBanner
    }

    public var onAdReceived: (() -> Void)?
    public var onAdExhausted: (() -> Void)?

    // MARK: - Data

    private let adUnitId: String
    private let policy: AdRetryPolicy
    private weak var googleBanner: GADBannerView?
    private weak var rootViewController: UIViewController?
    private var retryCount: Int = 0
    private var loadTimeoutWorkItem: DispatchWorkItem?
    private var retryWorkItem: DispatchWorkItem?

    // MARK: - Init

    public init(adUnitId: String, policy: AdRetryPolicy = .default) {
        self.adUnitId = adUnitId
        self.policy = policy
        super.init()
    }

    deinit {
        self.cancelLoadTimeout()
        self.cancelRetry()
    }

    // MARK: - BannerAdLoading 구현

    public func createBannerView(rootViewController: UIViewController) -> UIView {
        self.rootViewController = rootViewController
        self.retryCount = 0
        self.cancelLoadTimeout()
        self.cancelRetry()

        let banner = GADBannerView(adSize: GADAdSizeBanner)
        banner.adUnitID = self.adUnitId
        banner.rootViewController = rootViewController
        banner.delegate = self
        banner.translatesAutoresizingMaskIntoConstraints = false
        self.googleBanner = banner

        self.loadAd()
        return banner
    }

    public func reload() {
        self.loadAd()
    }

    public func reset() {
        self.retryCount = 0
        self.cancelLoadTimeout()
        self.cancelRetry()
        if self.googleBanner != nil {
            self.loadAd()
        }
    }

    // MARK: - Load

    private func loadAd() {
        guard let banner = self.googleBanner else { return }
        self.scheduleLoadTimeout()
        banner.load(GADRequest())
        STAdLogger.debug("[Google] 배너 로드 요청 (시도 \(self.retryCount + 1)/\(self.policy.maxRetryCount))")
    }

    // MARK: - Timeout

    private func scheduleLoadTimeout() {
        self.cancelLoadTimeout()
        let work = DispatchWorkItem(block: { [weak self] in
            guard let self = self else { return }
            STAdLogger.warning("[Google] 배너 로드 timeout (응답 없음, \(self.policy.loadTimeout)초)")
            self.handleLoadFailure(reason: "timeout")
        })
        self.loadTimeoutWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + self.policy.loadTimeout, execute: work)
    }

    private func cancelLoadTimeout() {
        self.loadTimeoutWorkItem?.cancel()
        self.loadTimeoutWorkItem = nil
    }

    // MARK: - Retry

    private func cancelRetry() {
        self.retryWorkItem?.cancel()
        self.retryWorkItem = nil
    }

    private func handleLoadFailure(reason: String) {
        self.cancelLoadTimeout()
        self.googleBanner?.isHidden = true

        guard self.retryCount < self.policy.maxRetryCount else {
            STAdLogger.warning("[Google] 배너 최대 재시도 횟수 초과 (\(self.policy.maxRetryCount)회) -> 폴백")
            self.onAdExhausted?()
            return
        }

        self.retryCount += 1
        STAdLogger.debug("[Google] 배너 \(self.policy.retryInterval)초 후 재시도 (\(self.retryCount)/\(self.policy.maxRetryCount), reason=\(reason))")

        let work = DispatchWorkItem(block: { [weak self] in
            guard let self = self else { return }
            self.loadAd()
        })
        self.retryWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + self.policy.retryInterval, execute: work)
    }
}

// MARK: - GADBannerViewDelegate

extension GoogleBannerConnector: GADBannerViewDelegate {

    public func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        self.cancelLoadTimeout()
        self.cancelRetry()
        self.retryCount = 0
        bannerView.isHidden = false
        STAdLogger.debug("[Google] 배너 광고 수신 완료")
        self.onAdReceived?()
    }

    public func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        STAdLogger.error("[Google] 배너 광고 로드 실패: \(error.localizedDescription)")
        self.handleLoadFailure(reason: "didFail")
    }
}
