//
//  AdRewardedPresenting.swift
//  STAdCore
//

import Foundation
import UIKit

/// 리워드 광고 프레젠터 공통 인터페이스
public protocol AdRewardedPresenting: AnyObject {

    /// 광고가 즉시 표시 가능한 상태인지
    var isReady: Bool { get }

    /// 미리 광고 로드
    func preload()

    /// 광고 표시
    /// - onRewarded: 사용자가 보상 획득 시 호출
    /// - onDismissed: 광고 닫힘 또는 표시 실패 시 호출 (보상 여부 무관)
    func present(
        from viewController: UIViewController,
        onRewarded: @escaping () -> Void,
        onDismissed: @escaping () -> Void
    )
}
