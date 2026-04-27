//
//  CoupangFallbackConfiguration.swift
//  STAdCore
//

import Foundation

public struct CoupangFallbackConfiguration {

    public let shortURL: URL
    public let subId: String?
    public let displayDuration: TimeInterval
    public let disclosureText: String

    public let bannerId: Int?
    public let trackingCode: String?
    public let bannerTemplate: String

    public init(
        shortURL: URL,
        subId: String? = nil,
        displayDuration: TimeInterval = 30,
        disclosureText: String = "이 포스팅은 쿠팡 파트너스 활동의 일환으로, 이에 따른 일정액의 수수료를 제공받습니다.",
        bannerId: Int? = nil,
        trackingCode: String? = nil,
        bannerTemplate: String = "carousel"
    ) {
        self.shortURL = shortURL
        self.subId = subId
        self.displayDuration = displayDuration
        self.disclosureText = disclosureText
        self.bannerId = bannerId
        self.trackingCode = trackingCode
        self.bannerTemplate = bannerTemplate
    }

    public var trackedURL: URL {
        guard let subId = self.subId, !subId.isEmpty else { return self.shortURL }
        var components = URLComponents(url: self.shortURL, resolvingAgainstBaseURL: false)
        var items = components?.queryItems ?? []
        items.append(URLQueryItem(name: "subId", value: subId))
        components?.queryItems = items
        return components?.url ?? self.shortURL
    }

    public func bannerHTML(width: Int, height: Int) -> String? {
        guard let bannerId = self.bannerId, let trackingCode = self.trackingCode else { return nil }
        let tsource = self.subId ?? ""
        return """
        <!DOCTYPE html>
        <html><head><meta charset='utf-8'><meta name='viewport' content='width=\(width), initial-scale=1'></head>
        <body style='margin:0;padding:0;background:transparent;'>
        <script src='https://ads-partners.coupang.com/g.js'></script>
        <script>
        new PartnersCoupang.G({"id":\(bannerId),"template":"\(self.bannerTemplate)","trackingCode":"\(trackingCode)","width":"\(width)","height":"\(height)","tsource":"\(tsource)"});
        </script>
        </body></html>
        """
    }
}
