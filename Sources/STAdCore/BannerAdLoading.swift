//
//  BannerAdLoading.swift
//  STAdCore
//

import Foundation
import UIKit

/// 배너 광고 로더의 공통 인터페이스
/// 각 네트워크(Google/Meta) connector가 채택
public protocol BannerAdLoading: AnyObject {

    /// 배너 뷰. 첫 load() 이전에는 nil 가능
    var bannerView: UIView? { get }

    /// 배너 광고가 수신되어 화면에 그려질 준비가 됐을 때 발화
    var onAdReceived: (() -> Void)? { get set }

    /// 재시도 정책 횟수 모두 소진 (silent timeout 포함) 시 발화. 폴백 트리거용
    var onAdExhausted: (() -> Void)? { get set }

    /// 배너 뷰 생성 후 광고 로드 시작
    /// 같은 connector 인스턴스에 두 번째 호출 시 기존 뷰 제거 후 재생성
    func createBannerView(rootViewController: UIViewController) -> UIView

    /// 외부에서 강제 로드 재시도. 카운터는 유지됨
    func reload()

    /// 카운터/타이머 모두 초기화 후 처음부터 다시 시작
    func reset()
}
