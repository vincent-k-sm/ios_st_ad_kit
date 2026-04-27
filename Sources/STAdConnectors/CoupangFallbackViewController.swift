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

    private lazy var topBarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        return view
    }()

    private lazy var countdownLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("닫기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.35), for: .disabled)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.isEnabled = false
        button.addTarget(self, action: #selector(self.didTapClose), for: .touchUpInside)
        return button
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

    private let configuration: CoupangFallbackConfiguration
    private var remainingSeconds: Int
    private var timer: Timer?
    private var onRewarded: (() -> Void)?
    private var onDismissed: (() -> Void)?

    // MARK: - Init

    init(
        configuration: CoupangFallbackConfiguration,
        onRewarded: @escaping () -> Void,
        onDismissed: @escaping () -> Void
    ) {
        self.configuration = configuration
        self.remainingSeconds = Int(configuration.displayDuration)
        self.onRewarded = onRewarded
        self.onDismissed = onDismissed
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        self.timer?.invalidate()
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.loadURL()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startCountdown()
    }

    // MARK: - Setup Methods

    private func setupUI() {
        self.view.backgroundColor = .black
        self.disclosureLabel.text = self.configuration.disclosureText

        self.view.addSubview(self.webView)
        self.view.addSubview(self.topBarView)
        self.topBarView.addSubview(self.countdownLabel)
        self.topBarView.addSubview(self.closeButton)
        self.view.addSubview(self.disclosureView)
        self.disclosureView.addSubview(self.disclosureLabel)

        NSLayoutConstraint.activate([
            self.webView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),

            self.topBarView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.topBarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topBarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topBarView.heightAnchor.constraint(equalToConstant: 44),

            self.countdownLabel.leadingAnchor.constraint(equalTo: self.topBarView.leadingAnchor, constant: 16),
            self.countdownLabel.centerYAnchor.constraint(equalTo: self.topBarView.centerYAnchor),

            self.closeButton.trailingAnchor.constraint(equalTo: self.topBarView.trailingAnchor, constant: -16),
            self.closeButton.centerYAnchor.constraint(equalTo: self.topBarView.centerYAnchor),

            self.disclosureView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.disclosureView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.disclosureView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),

            self.disclosureLabel.topAnchor.constraint(equalTo: self.disclosureView.topAnchor, constant: 8),
            self.disclosureLabel.bottomAnchor.constraint(equalTo: self.disclosureView.bottomAnchor, constant: -8),
            self.disclosureLabel.leadingAnchor.constraint(equalTo: self.disclosureView.leadingAnchor, constant: 12),
            self.disclosureLabel.trailingAnchor.constraint(equalTo: self.disclosureView.trailingAnchor, constant: -12),
        ])

        self.updateCountdownLabel()
    }

    private func loadURL() {
        let request = URLRequest(url: self.configuration.trackedURL)
        self.webView.load(request)
    }

    private func startCountdown() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            self.remainingSeconds -= 1
            self.updateCountdownLabel()

            if self.remainingSeconds <= 0 {
                self.timer?.invalidate()
                self.timer = nil
                self.onRewarded?()
                self.onRewarded = nil
                self.closeButton.isEnabled = true
            }
        })
    }

    private func updateCountdownLabel() {
        if self.remainingSeconds > 0 {
            self.countdownLabel.text = "\(self.remainingSeconds)초 남음"
        }
        else {
            self.countdownLabel.text = ""
        }
    }

    // MARK: - Actions

    @objc private func didTapClose() {
        self.timer?.invalidate()
        self.timer = nil
        let dismissed = self.onDismissed
        self.onDismissed = nil
        self.dismiss(animated: true, completion: {
            dismissed?()
        })
    }
}
