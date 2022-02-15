//
//  PlayerPageViewController.swift
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

import UIKit

class PlayerPageViewController: UIViewController {
    
    // MARK: - properties
    
    var playerPageViewModel: PlayerPageViewModel?
    
    // MARK: - UI properties
    
    private lazy var playerPageView: PlayerPageView = {
        let playerPageView = PlayerPageView()
        playerPageView.delegate = self
        return playerPageView
    }()
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setEpisodePageView()
        binding()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        playerPageViewModel = nil
    }
    
    // MARK: - init / deinit
    
    deinit {
        print("PlayerPageViewController Deinit")
    }
    
    // MARK: - method
    
    func setEpisodePageView() {
        view.addSubview(playerPageView)
        playerPageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerPageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerPageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerPageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            playerPageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func binding() {
        guard let playerPageViewModel = playerPageViewModel else { return }
        
        playerPageViewModel.epImageUrl.bind { [weak self] imageUrl in
            guard let self = self else { return }
            self.playerPageView.epImageView.loadImage(imageUrl, placeHolder: nil)
        }

        playerPageViewModel.epTitle.bind { [weak self] epTitle in
            guard let self = self else { return }
            self.playerPageView.epTitleLabel.text = epTitle
        }
        
        playerPageViewModel.playButtonType.bind { [weak self] playButtonType in
            guard let self = self else { return }
            self.togglePlayButtonImage(playButtonType)
        }
        
        playerPageViewModel.playProgress.bind { [weak self] playProgress in
            guard let self = self else { return }
            self.playerPageView.progressSlider.value = playProgress
        }
    }
    
    func togglePlayButtonImage(_ playButtonType:PlayButtonType) {
        let config = UIImage.SymbolConfiguration(pointSize: 100)
        let bigImage = UIImage(systemName: playButtonType.systemName, withConfiguration: config)
        playerPageView.playeButton.setImage(bigImage, for: .normal)
    }
    
}

// MARK: - PlayerPageViewDelegate

extension PlayerPageViewController: PlayerPageViewDelegate {
    
    func pauseToSeek(_ playerPageView: PlayerPageView) {
        guard let playerPageViewModel = playerPageViewModel else { return }
        playerPageViewModel.pausePlayer()
    }
    
    func handleTap(_ playerPageView: PlayerPageView, tapType: PlayerPageViewTapType) {
        
        guard let playerPageViewModel = playerPageViewModel else { return }
        
        switch tapType {
            
        case .togglePlay:
            playerPageViewModel.togglePlay()
            
        case .switchItem(let switchType):
            playerPageViewModel.switchToItem(switchType)
            
        }
    }
    
    func handleSliderEvent(_ playerPageView: PlayerPageView, sliderEventType: PlayerPageViewSliderEventType) {
        guard let playerPageViewModel = playerPageViewModel else { return }
        
        switch sliderEventType {
        case .progressValueChange(let sliderValue):
            playerPageViewModel.slideToTime(Double(sliderValue))
        case .progressTouchEnd(let sliderValue):
            playerPageViewModel.sliderTouchEnded(Double(sliderValue))
        }
    }
    
}
