//
//  EpisodePageViewController.swift
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

import UIKit
import RxSwift

class EpisodePageViewController: UIViewController {
    
    // MARK: - properties
    
    var episodePageViewModel: EpisodePageViewModel?
	let bag = DisposeBag()
    
    // MARK: - UI properties
    
    private lazy var episodePageView: EpisodePageView = {
        let episodePageView = EpisodePageView()
        episodePageView.delegate = self
        episodePageView.descriptionTextView.delegate = self
        return episodePageView
    }()
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setEpisodePageView()
        binding()
    }
    
    // MARK: - init / deinit
    
    deinit {
        print("EpisodePageViewController Deinit")
        episodePageViewModel = nil
    }
    
    // MARK: - config UI method
    
    func setEpisodePageView() {
        view.addSubview(episodePageView)
        episodePageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            episodePageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            episodePageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            episodePageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            episodePageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - method
    
    func binding() {
        
        guard let episodePageViewModel = episodePageViewModel else { return }

		episodePageViewModel.podcastTitle.subscribe(onNext: { string in
			self.episodePageView.podcastTitleLabel.text = string
		}).disposed(by: bag)

		episodePageViewModel.epTitle.subscribe(onNext: { string in
			self.episodePageView.epTitleLabel.text = string
		}).disposed(by: bag)

		episodePageViewModel.epDescription.subscribe(onNext: { string in
			self.episodePageView.descriptionTextView.text = string
		}).disposed(by: bag)

		episodePageViewModel.epImageUrl.subscribe(onNext: { string in
			self.episodePageView.epImageView.loadImage(string)
		}).disposed(by: bag)

    }
    
    func presentPlayerPage(playerPageViewModel: PlayerPageViewModel) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let playerPageViewController = storyboard.instantiateViewController(withIdentifier: PlayerPageViewController.reuseIdentifier) as? PlayerPageViewController else { return }
        playerPageViewController.playerPageViewModel = playerPageViewModel
        present(playerPageViewController, animated: true)
    }
    
}

// MARK: - EpisodePageViewDelegate

extension EpisodePageViewController: EpisodePageViewDelegate {
    
    func handleTap(_ episodePageView: EpisodePageView) {
        guard let episodePageViewModel = episodePageViewModel else { return }
        let playerPageViewModel = episodePageViewModel.createPlayerPageViewModel()
        presentPlayerPage(playerPageViewModel: playerPageViewModel)
    }
    
}

// MARK: - UITextViewDelegate

extension EpisodePageViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        true
    }
}
