//
//  CoupangPartnersInterstitialConnector.swift
//  STAdConnectors
//

import STAdCore
import UIKit

public final class CoupangPartnersInterstitialConnector: AdInterstitialPresenting {

    // MARK: - Data

    private let configuration: CoupangFallbackConfiguration

    // MARK: - Init

    public init(configuration: CoupangFallbackConfiguration) {
        self.configuration = configuration
    }

    deinit { }

    // MARK: - AdInterstitialPresenting

    public var isReady: Bool {
        return true
    }

    public func preload() { }

    public func present(from viewController: UIViewController, completion: @escaping () -> Void) {
        let vc = CoupangFallbackViewController(
            configuration: self.configuration,
            onRewarded: { },
            onDismissed: completion
        )
        viewController.present(vc, animated: true)
    }
}
