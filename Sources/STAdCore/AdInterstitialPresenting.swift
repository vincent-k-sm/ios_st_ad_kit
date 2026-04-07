//
//  AdInterstitialPresenting.swift
//  STAdCore
//

import Foundation
import UIKit

/// 인터스티셜 광고 프레젠터 공통 인터페이스
public protocol AdInterstitialPresenting: AnyObject {

    /// 광고가 즉시 표시 가능한 상태인지
    var isReady: Bool { get }

    /// 미리 광고 로드
    func preload()

    /// 광고 표시. completion은 광고 dismiss 시점에 호출 (광고 표시 실패 시에도 호출)
    func present(from viewController: UIViewController, completion: @escaping () -> Void)
}
