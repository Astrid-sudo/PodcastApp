//
//  EpisodePageViewController.swift
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

import UIKit

class EpisodePageViewController: UIViewController {
    
    // MARK: - properties
    
    var episodePageViewModel: EpisodePageViewModel?
    
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
        
        episodePageViewModel.podcastTitle.bind { [weak self] podcastTitle in
            guard let self = self else { return }
            self.episodePageView.podcastTitleLabel.text = podcastTitle
        }
        
        episodePageViewModel.epTitle.bind { [weak self] epTitle in
            guard let self = self else { return }
            self.episodePageView.epTitleLabel.text = epTitle
        }
        
        episodePageViewModel.epDescription.bind { [weak self] epDescription in
            guard let self = self else { return }
            self.episodePageView.descriptionTextView.text = epDescription
        }
        
        episodePageViewModel.epImageUrl.bind { [weak self] epImageString in
            guard let self = self else { return }
            self.episodePageView.epImageView.loadImage(epImageString)
        }
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
