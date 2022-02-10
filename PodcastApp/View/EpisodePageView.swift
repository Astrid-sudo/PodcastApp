//
//  EpisodePageView.swift
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

import UIKit

protocol EpisodePageViewDelegate: AnyObject {
    func handleTap(_ episodePageView: EpisodePageView)
}

class EpisodePageView: UIView {
    
    init() {
        super.init(frame: CGRect())
        setEpisodeImage()
        setPodcastTitleLabel()
        setEpisodeTitleLabel()
        setEpisodeDescription()
        setPresentPlayerButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var delegate: EpisodePageViewDelegate?
    
     lazy var epImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()

     lazy var podcastTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .left
        label.font = UIFont(name: "PingFang TC", size: 18)
        return label
    }()
    
     lazy var epTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.textAlignment = .left
        label.font = UIFont(name: "PingFang TC", size: 14)
        label.numberOfLines = 0
        return label
    }()

    lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = .black
        textView.font = UIFont(name: "PingFang TC", size: 12)
        textView.textAlignment = .left
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        textView.indicatorStyle = .black
        textView.dataDetectorTypes = .link
        return textView
    }()
    
    private lazy var presentPlayerButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 100)
        let bigImage = UIImage(systemName: "play.circle", withConfiguration: config)
        button.setImage(bigImage, for: .normal)
        button.tintColor = .blue
        button.addTarget(self, action: #selector(tapPlayerButton), for: .touchUpInside)
        return button
    }()
    
    let padding: CGFloat = 16
    
    // MARK: - Action
    
    @objc func tapPlayerButton() {
        delegate?.handleTap(self)
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
    
    private func setPodcastTitleLabel() {
        self.addSubview(podcastTitleLabel)
        podcastTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            podcastTitleLabel.leadingAnchor.constraint(equalTo: epImageView.leadingAnchor, constant: padding),
            podcastTitleLabel.trailingAnchor.constraint(equalTo: epImageView.trailingAnchor, constant: -padding),
            podcastTitleLabel.topAnchor.constraint(equalTo: epImageView.topAnchor, constant: padding)
        ])
    }
    
    private func setEpisodeTitleLabel() {
        self.addSubview(epTitleLabel)
        epTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            epTitleLabel.leadingAnchor.constraint(equalTo: podcastTitleLabel.leadingAnchor),
            epTitleLabel.trailingAnchor.constraint(equalTo: epImageView.trailingAnchor, constant: -padding),
            epTitleLabel.topAnchor.constraint(equalTo: podcastTitleLabel.bottomAnchor, constant: 2 * padding)
        ])
    }
    
    private func setEpisodeDescription() {
        self.addSubview(descriptionTextView)
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionTextView.leadingAnchor.constraint(equalTo: epImageView.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: epImageView.trailingAnchor),
            descriptionTextView.topAnchor.constraint(equalTo: epImageView.bottomAnchor, constant: padding),
            descriptionTextView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.25)
        ])
    }
    
    private func setPresentPlayerButton() {
        self.addSubview(presentPlayerButton)
        presentPlayerButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            presentPlayerButton.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: padding),
            presentPlayerButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            presentPlayerButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -padding)
        ])
    }

}
