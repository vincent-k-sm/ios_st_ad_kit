//
//  BannerCoordinator.swift
//  STAdConnectors
//

import Foundation
import STAdCore
import UIKit

/// 두 배너 connector(primary/secondary) 사이의 폴백/cooldown 조정자
///
/// 흐름:
/// - start() 호출 시 primary로 시작
/// - primary가 onAdExhausted 발화하면 secondary 시도
/// - secondary도 onAdExhausted 발화하면 cooldown(기본 5분) 후 primary 처음부터 다시 시도
/// - 한 사이클 내에서는 같은 connector 두 번 시도하지 않음 (ping-pong 방지)
public final class BannerCoordinator {

    // MARK: - Public

    /// 활성 배너 뷰가 변경될 때 호출. nil이면 모든 슬롯 소진 또는 정지 상태.
    public var onActiveBannerChanged: ((UIView?) -> Void)?

    // MARK: - Data

    private let primary: BannerAdLoading
    private let secondary: BannerAdLoading?
    private let cooldown: TimeInterval

    private weak var rootViewController: UIViewController?
    private var nextCycleWorkItem: DispatchWorkItem?

    // MARK: - Init

    public init(
        primary: BannerAdLoading,
        secondary: BannerAdLoading? = nil,
        cooldown: TimeInterval = 300
    ) {
        self.primary = primary
        self.secondary = secondary
        self.cooldown = cooldown
        self.bindCallbacks()
    }

    deinit {
        self.cancelNextCycle()
    }

    // MARK: - Public API

    /// 배너 사이클을 시작 (primary 슬롯부터)
    public func start(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        self.cancelNextCycle()
        self.activatePrimary()
    }

    /// 사이클 정지 + cooldown 타이머 취소 + 활성 배너 nil 알림
    public func stop() {
        self.cancelNextCycle()
        self.notifyActiveBanner(nil)
    }

    // MARK: - Internal

    private func bindCallbacks() {
        self.primary.onAdExhausted = { [weak self] in
            guard let self = self else { return }
            self.handleExhausted(slot: .primary)
        }
        self.secondary?.onAdExhausted = { [weak self] in
            guard let self = self else { return }
            self.handleExhausted(slot: .secondary)
        }
    }

    private func activatePrimary() {
        guard let root = self.rootViewController else { return }
        STAdLogger.debug("[Coordinator] primary 슬롯 시작")
        self.primary.reset()
        let view = self.primary.createBannerView(rootViewController: root)
        self.notifyActiveBanner(view)
    }

    private func activateSecondary() {
        guard let root = self.rootViewController, let secondary = self.secondary else {
            self.scheduleNextCycle()
            return
        }
        STAdLogger.debug("[Coordinator] secondary 슬롯 시작")
        secondary.reset()
        let view = secondary.createBannerView(rootViewController: root)
        self.notifyActiveBanner(view)
    }

    private func handleExhausted(slot: Slot) {
        STAdLogger.warning("[Coordinator] \(slot) 슬롯 소진")
        switch slot {
            case .primary:
                if self.secondary != nil {
                    self.activateSecondary()
                }
                else {
                    self.scheduleNextCycle()
                }

            case .secondary:
                self.scheduleNextCycle()
        }
    }

    private func scheduleNextCycle() {
        self.cancelNextCycle()
        STAdLogger.warning("[Coordinator] 모든 슬롯 소진 -> \(self.cooldown)초 후 사이클 재시작")
        self.notifyActiveBanner(nil)

        let work = DispatchWorkItem(block: { [weak self] in
            guard let self = self else { return }
            self.activatePrimary()
        })
        self.nextCycleWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + self.cooldown, execute: work)
    }

    private func cancelNextCycle() {
        self.nextCycleWorkItem?.cancel()
        self.nextCycleWorkItem = nil
    }

    /// onActiveBannerChanged 콜백을 항상 메인 스레드에서 직렬로 호출.
    /// connector(Google/Meta SDK)의 ad delegate 콜백이 어느 스레드에서 발화되든
    /// 호출 측(BrowserViewController 등)이 UIKit 작업을 안전하게 수행하도록 보장.
    private func notifyActiveBanner(_ view: UIView?) {
        if Thread.isMainThread {
            self.onActiveBannerChanged?(view)
        }
        else {
            DispatchQueue.main.async(execute: { [weak self] in
                self?.onActiveBannerChanged?(view)
            })
        }
    }
}

// MARK: - Slot

private extension BannerCoordinator {
    enum Slot: String, CustomStringConvertible {
        case primary
        case secondary

        var description: String { return self.rawValue }
    }
}
