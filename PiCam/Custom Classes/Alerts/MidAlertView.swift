//
//  Untitled.swift
//  PiCam
//
//  Created by Tyson Miles on 7/4/2025.
//
import UIKit

enum AlertType {
    case loading
    case success
    case alert
    case loadingcustom 
}

class MidAlertView: UIView {
    private var type: AlertType
    private var title: String?
    private var customLoadingImage: UIImageView?
    private var message: String?
    private var symbol: UIImage?
    private var primaryAction: (() -> Void)?
    private var primaryActionName: String?
    private var secondaryActionName: String?
    private var secondaryActionColor: UIColor?
    private var primaryActionColor: UIColor?
    private var secondaryAction: (() -> Void)?
    
    private let contentView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemMaterialDark)
        let view = UIVisualEffectView(effect: effect)
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    init(type: AlertType, title: String?, message: String?, symbol: UIImage? = nil,
         primaryAction: (() -> Void)? = nil, secondaryActionName: String? = nil,
         primaryActionName: String? = nil, primaryActionColor: UIColor? = nil,
         secondaryActionColor: UIColor? = nil, secondaryAction: (() -> Void)? = nil) {
        self.type = type
        self.title = title
        self.message = message
        self.symbol = symbol
        self.primaryAction = primaryAction
        self.primaryActionName = primaryActionName
        self.secondaryActionName = secondaryActionName
        self.secondaryAction = secondaryAction
        self.secondaryActionColor = secondaryActionColor
        self.primaryActionColor = primaryActionColor
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupView() {
        // Dimming background
        let dimmingView = UIView()
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(dimmingView)
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dimmingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimmingView.topAnchor.constraint(equalTo: topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Content View
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentView.widthAnchor.constraint(equalToConstant: 280)
        ])
        
        // Content Stack
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 7
        stackView.alignment = .center
        stackView.distribution = .fill
        contentView.contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.contentView.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: contentView.contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.contentView.bottomAnchor, constant: -24)
        ])
        
        // Icon/Indicator
        switch type {
        case .loading:
            let indicator = UIActivityIndicatorView(style: .large)
            indicator.color = .white
            indicator.startAnimating()
            stackView.addArrangedSubview(indicator)
            // Inside the switch statement for .success and .alert cases:
        case .success:
            if let symbol = symbol {
                let imageView = UIImageView(image: symbol)
                imageView.tintColor = .white
                imageView.contentMode = .scaleAspectFit // Changed content mode
                imageView.heightAnchor.constraint(equalToConstant: 42).isActive = true // Increased height
                imageView.widthAnchor.constraint(equalToConstant: 42).isActive = true // Optional: Set width
                stackView.addArrangedSubview(imageView)
            }
        case .alert:
            if let symbol = symbol {
                let imageView = UIImageView(image: symbol)
                imageView.tintColor = .white
                imageView.contentMode = .scaleAspectFit // Changed content mode
                imageView.heightAnchor.constraint(equalToConstant: 42).isActive = true // Increased height
                imageView.widthAnchor.constraint(equalToConstant: 42).isActive = true // Optional: Set width
                stackView.addArrangedSubview(imageView)
            }
        case .loadingcustom: // NEW CASE
                    if let symbol = symbol {
                        let imageView = UIImageView(image: symbol)
                        imageView.tintColor = .white
                        imageView.contentMode = .scaleAspectFit
                        imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
                        imageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
                        stackView.addArrangedSubview(imageView)
                        addRotationAnimation(to: imageView)
                        customLoadingImage = imageView // Store reference
                    }
        }
        // Title
        if let title = title {
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            titleLabel.textColor = .white
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .center
            stackView.addArrangedSubview(titleLabel)
        }
        
        // Message
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        messageLabel.textColor = .white.withAlphaComponent(0.9)
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        stackView.addArrangedSubview(messageLabel)
        
        // Buttons
if type == .alert {
                    let buttonStack = UIStackView()
                    buttonStack.axis = .vertical
                    buttonStack.spacing = 8
                    buttonStack.distribution = .fillEqually
                    
    let primaryButton = UIButton(type: .system)
                    primaryButton.setTitle(primaryActionName, for: .normal)
                    primaryButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
                    primaryButton.setTitleColor(.white, for: .normal) // Fixed text color
                    primaryButton.backgroundColor = primaryActionColor
                    primaryButton.layer.cornerRadius = 8
                    primaryButton.addTarget(self, action: #selector(handlePrimary), for: .touchUpInside)
                    
                    let secondaryButton = UIButton(type: .system)
                    secondaryButton.setTitle(secondaryActionName, for: .normal)
                    secondaryButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
                    secondaryButton.setTitleColor(.white, for: .normal) // Fixed text color
                    secondaryButton.backgroundColor = secondaryActionColor
                    secondaryButton.layer.cornerRadius = 8
                    secondaryButton.addTarget(self, action: #selector(handleSecondary), for: .touchUpInside)
    
                    buttonStack.addArrangedSubview(secondaryButton)
                    buttonStack.addArrangedSubview(primaryButton)
                    stackView.addArrangedSubview(buttonStack)
                    
                    NSLayoutConstraint.activate([
                        primaryButton.heightAnchor.constraint(equalToConstant: 44),
                        secondaryButton.heightAnchor.constraint(equalToConstant: 44),
                        buttonStack.widthAnchor.constraint(equalTo: stackView.widthAnchor)
                    ])
                }
            }
    private func addRotationAnimation(to view: UIImageView) {
            let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1.1
            rotation.isCumulative = true
            rotation.repeatCount = .infinity
            view.layer.add(rotation, forKey: "rotationAnimation")
        }
        
        // NEW METHOD: Update custom loading image
        func updateCustomLoadingImage(_ image: UIImage?) {
            customLoadingImage?.image = image?.withRenderingMode(.alwaysTemplate)
            
            // Restart animation if needed
            if let imageView = customLoadingImage, imageView.layer.animation(forKey: "rotationAnimation") == nil {
                addRotationAnimation(to: imageView)
            }
        }
    
    func show(in view: UIView, duration: TimeInterval = 3.0) {
        view.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        } completion: { _ in
            if self.type != .alert {
                UIView.animate(withDuration: 0.3, delay: duration) {
                    self.alpha = 0
                } completion: { _ in
                    self.removeFromSuperview()
                }
            }
        }
    }
    
    @objc private func handlePrimary() {
        primaryAction?()
        dismiss()
    }
    
    @objc private func handleSecondary() {
        secondaryAction?()
        dismiss()
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}
