//
//  CoupangPartnersRewardedConnector.swift
//  STAdConnectors
//

import STAdCore
import UIKit

public final class CoupangPartnersRewardedConnector: AdRewardedPresenting {

    // MARK: - Data

    private let configuration: CoupangFallbackConfiguration

    // MARK: - Init

    public init(configuration: CoupangFallbackConfiguration) {
        self.configuration = configuration
    }

    deinit { }

    // MARK: - AdRewardedPresenting

    public var isReady: Bool {
        return true
    }

    public func preload() { }

    public func present(
        from viewController: UIViewController,
        onRewarded: @escaping () -> Void,
        onDismissed: @escaping () -> Void
    ) {
        let vc = CoupangFallbackViewController(
            configuration: self.configuration,
            onRewarded: onRewarded,
            onDismissed: onDismissed
        )
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        viewController.present(nav, animated: true)
    }
}
