//
//  AdRetryPolicy.swift
//  STAdCore
//

import Foundation

/// 광고 로드 재시도 정책
public struct AdRetryPolicy {

    /// 최대 재시도 횟수 (이 횟수 도달 시 onExhausted 발화)
    public let maxRetryCount: Int

    /// 재시도 간격 (초). 단순 고정 간격 사용
    public let retryInterval: TimeInterval

    /// load() 호출 후 콜백이 안 오는 경우의 timeout (초)
    /// silent stuck 방지용
    public let loadTimeout: TimeInterval

    public init(
        maxRetryCount: Int,
        retryInterval: TimeInterval,
        loadTimeout: TimeInterval
    ) {
        self.maxRetryCount = maxRetryCount
        self.retryInterval = retryInterval
        self.loadTimeout = loadTimeout
    }

    /// 기본 정책: 최대 30회 재시도, 30초 간격, 15초 로드 timeout
    public static let `default` = AdRetryPolicy(
        maxRetryCount: 30,
        retryInterval: 30,
        loadTimeout: 15
    )
}
