//
//  CoupangFallbackViewController.swift
//  STAdConnectors
//

import STAdCore
import UIKit
import WebKit

final class CoupangFallbackViewController: UIViewController {

    // MARK: - UI Components

    private lazy var webView: WKWebView = {
        let view = WKWebView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var disclosureView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        return view
    }()

    private lazy var disclosureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 11)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    // MARK: - Data

    /// 쿠팡 파트너스는 CPS(클릭 후 구매) 모델이라 노출 시간이 수익에 영향 없음.
    /// 카운트다운/강제 시청은 무의미하며, 사용자 자율(즉시 닫기 가능)이 클릭률 측면에서 더 유리.
    private let configuration: CoupangFallbackConfiguration
    private var onRewarded: (() -> Void)?
    private var onDismissed: (() -> Void)?

    // MARK: - Init

    init(
        configuration: CoupangFallbackConfiguration,
        onRewarded: @escaping () -> Void,
        onDismissed: @escaping () -> Void
    ) {
        self.configuration = configuration
        self.onRewarded = onRewarded
        self.onDismissed = onDismissed
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit { }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationItem()
        self.setupUI()
        self.loadURL()
    }

    // MARK: - Setup Methods

    private func setupNavigationItem() {
        let closeButton = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(self.didTapClose)
        )
        self.navigationItem.rightBarButtonItem = closeButton
        self.navigationItem.title = "광고"
    }

    private func setupUI() {
        self.view.backgroundColor = .systemBackground
        self.disclosureLabel.text = self.configuration.disclosureText

        self.view.addSubview(self.webView)
        self.view.addSubview(self.disclosureView)
        self.disclosureView.addSubview(self.disclosureLabel)

        let safe = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            self.webView.topAnchor.constraint(equalTo: safe.topAnchor),
            self.webView.bottomAnchor.constraint(equalTo: self.disclosureView.topAnchor),
            self.webView.leadingAnchor.constraint(equalTo: safe.leadingAnchor),
            self.webView.trailingAnchor.constraint(equalTo: safe.trailingAnchor),

            self.disclosureView.leadingAnchor.constraint(equalTo: safe.leadingAnchor),
            self.disclosureView.trailingAnchor.constraint(equalTo: safe.trailingAnchor),
            self.disclosureView.bottomAnchor.constraint(equalTo: safe.bottomAnchor),

            self.disclosureLabel.topAnchor.constraint(equalTo: self.disclosureView.topAnchor, constant: 8),
            self.disclosureLabel.bottomAnchor.constraint(equalTo: self.disclosureView.bottomAnchor, constant: -8),
            self.disclosureLabel.leadingAnchor.constraint(equalTo: self.disclosureView.leadingAnchor, constant: 12),
            self.disclosureLabel.trailingAnchor.constraint(equalTo: self.disclosureView.trailingAnchor, constant: -12),
        ])
    }

    private func loadURL() {
        let request = URLRequest(url: self.configuration.trackedURL)
        self.webView.load(request)
    }

    // MARK: - Actions

    @objc private func didTapClose() {
        let dismissed = self.onDismissed
        self.onDismissed = nil
        self.onRewarded = nil
        self.dismiss(animated: true, completion: {
            dismissed?()
        })
    }
}
