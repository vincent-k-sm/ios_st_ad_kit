//
//  CoupangPartnersBannerConnector.swift
//  STAdConnectors
//

import STAdCore
import UIKit
import WebKit

public final class CoupangPartnersBannerConnector: NSObject, BannerAdLoading {

    // MARK: - BannerAdLoading

    public var bannerView: UIView? {
        return self.webView
    }

    public var onAdReceived: (() -> Void)?
    public var onAdExhausted: (() -> Void)?

    // MARK: - Data

    private let configuration: CoupangFallbackConfiguration
    private let width: Int
    private let height: Int
    private let policy: AdRetryPolicy
    private var webView: WKWebView?
    private var retryCount: Int = 0
    private var retryWorkItem: DispatchWorkItem?

    // MARK: - Init

    public init(
        configuration: CoupangFallbackConfiguration,
        width: Int = 320,
        height: Int = 50,
        policy: AdRetryPolicy = .default
    ) {
        self.configuration = configuration
        self.width = width
        self.height = height
        self.policy = policy
        super.init()
    }

    deinit {
        self.cancelRetry()
    }

    // MARK: - BannerAdLoading 구현

    public func createBannerView(rootViewController: UIViewController) -> UIView {
        self.retryCount = 0
        self.cancelRetry()

        let config = WKWebViewConfiguration()
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.navigationDelegate = self
        wv.scrollView.isScrollEnabled = false
        wv.scrollView.bounces = false
        wv.isOpaque = false
        wv.backgroundColor = .clear
        wv.translatesAutoresizingMaskIntoConstraints = false
        self.webView = wv

        self.loadHTML()
        return wv
    }

    public func reload() {
        self.loadHTML()
    }

    public func reset() {
        self.retryCount = 0
        self.cancelRetry()
        if self.webView != nil {
            self.loadHTML()
        }
    }

    // MARK: - Load

    private func loadHTML() {
        guard let wv = self.webView,
              let html = self.configuration.bannerHTML(width: self.width, height: self.height) else {
            STAdLogger.warning("[Coupang] bannerHTML 생성 실패 (bannerId/trackingCode 없음)")
            self.onAdExhausted?()
            return
        }
        STAdLogger.debug("[Coupang] 배너 로드 요청 (시도 \(self.retryCount + 1)/\(self.policy.maxRetryCount))")
        wv.loadHTMLString(html, baseURL: URL(string: "https://ads-partners.coupang.com")!)
    }

    // MARK: - Retry

    private func cancelRetry() {
        self.retryWorkItem?.cancel()
        self.retryWorkItem = nil
    }

    private func handleLoadFailure(reason: String) {
        guard self.retryCount < self.policy.maxRetryCount else {
            STAdLogger.warning("[Coupang] 배너 최대 재시도 횟수 초과 (\(self.policy.maxRetryCount)회) -> 폴백")
            self.onAdExhausted?()
            return
        }

        self.retryCount += 1
        STAdLogger.debug("[Coupang] 배너 \(self.policy.retryInterval)초 후 재시도 (\(self.retryCount)/\(self.policy.maxRetryCount), reason=\(reason))")

        let work = DispatchWorkItem(block: { [weak self] in
            guard let self = self else { return }
            self.loadHTML()
        })
        self.retryWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + self.policy.retryInterval, execute: work)
    }
}

// MARK: - WKNavigationDelegate

extension CoupangPartnersBannerConnector: WKNavigationDelegate {

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.cancelRetry()
        self.retryCount = 0
        webView.isHidden = false
        STAdLogger.debug("[Coupang] 배너 로드 완료")
        self.onAdReceived?()
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        STAdLogger.error("[Coupang] 배너 로드 실패: \(error.localizedDescription)")
        self.handleLoadFailure(reason: "didFail")
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        STAdLogger.error("[Coupang] 배너 provisional 로드 실패: \(error.localizedDescription)")
        self.handleLoadFailure(reason: "didFailProvisional")
    }
}
