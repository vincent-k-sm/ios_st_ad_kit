# STAdKit

Google AdMob + Meta Audience Network 광고를 일관된 인터페이스로 다루기 위한 Swift Package.

`STPaywallKit`과 동일한 Core/Connectors 분리 구조를 따른다.

## 구조

- **STAdCore**: SDK 의존성 0. 프로토콜과 모델만 정의.
  - `BannerAdLoading`, `AdInterstitialPresenting`, `AdRewardedPresenting`
  - `AdConfiguration`, `AdRetryPolicy`
  - `STAdLogger` (OSLog 래퍼)
- **STAdConnectors**: Google/Meta SDK 구현체 + 폴백 코디네이터.
  - `GoogleBannerConnector`, `MetaBannerConnector`
  - `GoogleInterstitialConnector`, `MetaInterstitialConnector`
  - `GoogleRewardedConnector`, `MetaRewardedConnector`
  - `BannerCoordinator` (primary/secondary 폴백 + cooldown)
  - `MetaInitializer`

## 폴백 정책

- 기본 `AdRetryPolicy`: 30회 재시도, 30초 간격, 15초 load timeout
- silent stuck(콜백 미수신) 시에도 timeout으로 폴백 트리거
- `BannerCoordinator`: primary 소진 → secondary → 양쪽 소진 시 5분 cooldown 후 사이클 재시작

## 사용 예 (앱 측 wrapper)

```swift
import STAdCore
import STAdConnectors

let google = GoogleBannerConnector(adUnitId: "...")
let meta = MetaBannerConnector(placementId: "...")
let coordinator = BannerCoordinator(primary: google, secondary: meta)

coordinator.onActiveBannerChanged = { view in
    // view를 컨테이너에 attach/detach
}
coordinator.start(rootViewController: vc)
```

## 라이선스

MIT
