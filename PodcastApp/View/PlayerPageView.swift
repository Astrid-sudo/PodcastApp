//
//  PlayerPageView.swift
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

import UIKit

enum PlayButtonType {
    case play
    case pause
    
    var systemName: String {
        switch self {
        case .pause: return "pause.circle"
        case .play: return "play.circle"
        }
    }
}

enum SwitchItemType {
    case next
    case previous
}

enum PlayerPageViewTapType {
    case togglePlay
    case switchItem(SwitchItemType)
}

enum PlayerPageViewSliderEventType {
    case progressValueChange(_ sliderValue: Float)
    case progressTouchEnd(_ sliderValue: Float)
}

protocol PlayerPageViewDelegate: AnyObject {
    
    func handleTap(_ playerPageView: PlayerPageView, tapType: PlayerPageViewTapType)
    
    func handleSliderEvent(_ playerPageView: PlayerPageView, sliderEventType: PlayerPageViewSliderEventType)
    
    func pauseToSeek(_ playerPageView: PlayerPageView)
}

class PlayerPageView: UIView {
    
    // MARK: - properties
    
    weak var delegate: PlayerPageViewDelegate?
    
    // MARK: - UI properties
    
    lazy var epImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.addIndicator()
        return image
    }()
    
    lazy var epTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.textAlignment = .left
        label.font = UIFont(name: "PingFang TC", size: 14)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var progressSlider: UISlider = {
        let slider = UISlider()
        slider.maximumTrackTintColor = .gray
        slider.minimumTrackTintColor = .systemBlue
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0
        slider.isEnabled = true
        slider.isContinuous = true
        slider.addTarget(self, action: #selector(progressSliderValueChanged), for: UIControl.Event.valueChanged)
        slider.addTarget(self, action: #selector(progressSliderTouchBegan), for: .touchDown)
        slider.addTarget(self, action: #selector(progressSliderTouchEnded), for: [.touchUpInside, .touchCancel, .touchUpOutside])
        return slider
    }()
    
    lazy var playeButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 65)
        let bigImage = UIImage(systemName: "play.circle", withConfiguration: config)
        button.setImage(bigImage, for: .normal)
        button.addTarget(self, action: #selector(togglePlay), for: .touchUpInside)
        return button
    }()
    
    private lazy var forwardButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 65)
        let bigImage = UIImage(systemName: "forward", withConfiguration: config)
        button.setImage(bigImage, for: .normal)
        button.addTarget(self, action: #selector(switchToNextItem), for: .touchUpInside)
        return button
    }()
    
    private lazy var backwardButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 65)
        let bigImage = UIImage(systemName: "backward", withConfiguration: config)
        button.setImage(bigImage, for: .normal)
        button.addTarget(self, action: #selector(switchToPreviousItem), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = padding / 4
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    let padding: CGFloat = 16
    
    // MARK: - init / deinit
    
    init() {
        super.init(frame: CGRect())
        setEpisodeImage()
        setEpisodeTitleLabel()
        setStackView()
        setProgressSlider()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Method
    
    private func setEpisodeImage() {
        self.addSubview(epImageView)
        epImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            epImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
            epImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding),
            epImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: padding),
            epImageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5)
        ])
    }
    
    private func setEpisodeTitleLabel() {
        self.addSubview(epTitleLabel)
        epTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            epTitleLabel.leadingAnchor.constraint(equalTo: epImageView.leadingAnchor),
            epTitleLabel.trailingAnchor.constraint(equalTo: epImageView.trailingAnchor),
            epTitleLabel.topAnchor.constraint(equalTo: epImageView.bottomAnchor, constant: padding)
        ])
    }
    
    private func setStackView() {
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
            stackView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -padding),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding)
        ])
        stackView.addArrangedSubview(backwardButton)
        stackView.addArrangedSubview(playeButton)
        stackView.addArrangedSubview(forwardButton)
    }
    
    private func setProgressSlider() {
        self.addSubview(progressSlider)
        progressSlider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressSlider.leadingAnchor.constraint(equalTo: epImageView.leadingAnchor),
            progressSlider.trailingAnchor.constraint(equalTo: epImageView.trailingAnchor),
            progressSlider.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -padding / 2)
        ])
    }
    
    // MARK: - Action
    
    @objc func togglePlay() {
        delegate?.handleTap(self, tapType: .togglePlay)
    }
    
    @objc func switchToNextItem() {
        delegate?.handleTap(self, tapType: .switchItem(.next))
    }
    
    @objc func switchToPreviousItem() {
        delegate?.handleTap(self, tapType: .switchItem(.previous))
    }
    
    @objc func progressSliderValueChanged() {
        delegate?.handleSliderEvent(self, sliderEventType: .progressValueChange(progressSlider.value))
    }
    
    @objc func progressSliderTouchBegan() {
        delegate?.pauseToSeek(self)
    }
    
    @objc func progressSliderTouchEnded() {
        delegate?.handleSliderEvent(self, sliderEventType: .progressTouchEnd(progressSlider.value))
    }
    
}
