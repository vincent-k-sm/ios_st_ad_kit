//
//  STAdLogger.swift
//  STAdCore
//

import Foundation
import OSLog

/// STAdKit 패키지 내부 전용 로거
/// 외부에서 의존성 주입 없이 OSLog만 사용 (Utils 등 외부 모듈 의존 회피)
public enum STAdLogger {

    private static let logger = Logger(subsystem: "com.stadkit", category: "ads")

    public static func debug(_ message: String) {
        Self.logger.debug("\(message, privacy: .public)")
    }

    public static func info(_ message: String) {
        Self.logger.info("\(message, privacy: .public)")
    }

    public static func warning(_ message: String) {
        Self.logger.warning("\(message, privacy: .public)")
    }

    public static func error(_ message: String) {
        Self.logger.error("\(message, privacy: .public)")
    }
}
