//
//  PlayerPageViewController.swift
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

import UIKit
import RxSwift

class PlayerPageViewController: UIViewController {
    
    // MARK: - properties
    
    var playerPageViewModel: PlayerPageViewModel?

	private let bag = DisposeBag()

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

		playerPageViewModel.output.epImageUrl
			.subscribe(onNext: { [weak self] imageUrl in
			guard let self = self else { return }
			self.playerPageView.epImageView.loadImage(imageUrl, placeHolder: nil)
		})
			.disposed(by: bag)

		playerPageViewModel.output.epTitle
			.subscribe(onNext: { [weak self] epTitle in
				guard let self = self else { return }
				self.playerPageView.epTitleLabel.text = epTitle
			})
			.disposed(by: bag)

		playerPageViewModel.output.playButtonType
			.subscribe(onNext: { [weak self] playButtonType in
				guard let self = self else { return }
				self.togglePlayButtonImage(playButtonType)
			})
			.disposed(by: bag)

		playerPageViewModel.output.playProgress
			.subscribe(onNext: { [weak self] playProgress in
				guard let self = self else { return }
				self.playerPageView.progressSlider.value = playProgress
			})
			.disposed(by: bag)

		playerPageViewModel.output.duration
			.subscribe(onNext: { [weak self] duration in
				guard let self = self else { return }
				self.playerPageView.durationLabel.text = duration
			})
			.disposed(by: bag)

		playerPageViewModel.output.currentTime
			.subscribe(onNext: { [weak self] currentTime in
				guard let self = self else { return }
				self.playerPageView.currentTimeLabel.text = currentTime
			})
			.disposed(by: bag)
    }
    
    func togglePlayButtonImage(_ playButtonType:PlayButtonType) {
        let config = UIImage.SymbolConfiguration(pointSize: 100)
        let bigImage = UIImage(systemName: playButtonType.systemName, withConfiguration: config)
        playerPageView.playButton.setImage(bigImage, for: .normal)
    }
    
}

// MARK: - PlayerPageViewDelegate

extension PlayerPageViewController: PlayerPageViewDelegate {
    
    func pauseToSeek(_ playerPageView: PlayerPageView) {
        guard let playerPageViewModel = playerPageViewModel else { return }
		playerPageViewModel.input.pausePlayer()
    }
    
    func handleTap(_ playerPageView: PlayerPageView, tapType: PlayerPageViewTapType) {
        
        guard let playerPageViewModel = playerPageViewModel else { return }
        
        switch tapType {
            
        case .togglePlay:
			playerPageViewModel.input.togglePlay()
            
        case .switchItem(let switchType):
			playerPageViewModel.input.switchToItem(switchType)
            
        }
    }
    
    func handleSliderEvent(_ playerPageView: PlayerPageView, sliderEventType: PlayerPageViewSliderEventType) {
        guard let playerPageViewModel = playerPageViewModel else { return }
        
        switch sliderEventType {
        case .progressValueChange(let sliderValue):
			playerPageViewModel.input.slideToTime(Double(sliderValue))
        case .progressTouchEnd(let sliderValue):
			playerPageViewModel.input.sliderTouchEnded(Double(sliderValue))
        }
    }
    
}
