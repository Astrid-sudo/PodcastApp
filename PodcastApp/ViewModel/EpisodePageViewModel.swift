//
//  EpisodePageViewModel.swift
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

import UIKit
import RxSwift
import RxRelay

struct PlayerDetail {
    let epTitle: String?
    let epImageUrl: String?
    let audioLinkUrl: String?
}

protocol EpisodePageViewModelType {
	var input: EpisodePageViewModelInput { get }
	var output: EpisodePageViewModelOutput { get }
}

protocol EpisodePageViewModelInput {
	func createPlayerPageViewModel() -> PlayerPageViewModel
}

protocol EpisodePageViewModelOutput {
	var podcastTitle: Observable<String> { get }
	var epTitle: Observable<String> { get }
	var epImageUrl: Observable<String> { get }
	var epDescription: Observable<String> { get }
}

class EpisodePageViewModel {
    
    // MARK: - properties be observed
    
	private let podcastTitleBehaviorRelay = BehaviorRelay<String>(value: "")
	private let epTitleBehaviorRelay = BehaviorRelay<String>(value: "")
	private let epImageUrlBehaviorRelay = BehaviorRelay<String>(value: "")
	private let epDescriptionBehaviorRelay = BehaviorRelay<String>(value: "")
	
    // MARK: - properties
    
    var episodeDetails = [EpisodeDetail]()
    var currentEpisodeIndex = 0
    
    // MARK: - init / deinit
    
    init(episodeDetails: [EpisodeDetail], currentEpisodeIndex: Int) {
        self.episodeDetails = episodeDetails
        self.currentEpisodeIndex = currentEpisodeIndex
        parseFeedItem()
    }
    
    init() {}
    
    deinit {
        print("EpisodePageViewModel Deinit")
    }
    
    // MARK: - method
    
    /// Parse feed item and store in local properties.
	private func parseFeedItem() {
        guard episodeDetails.count > currentEpisodeIndex else { return }
        let currentEpisodeDetail = episodeDetails[currentEpisodeIndex]
        guard let podcastTitile = currentEpisodeDetail.podcastTitile,
              let epTitle = currentEpisodeDetail.epTitle,
              let epImage = currentEpisodeDetail.epImageUrl ,
              let epDescription = currentEpisodeDetail.epDescription else { return }
		self.podcastTitleBehaviorRelay.accept(podcastTitile)
        self.epTitleBehaviorRelay.accept(epTitle)
        self.epImageUrlBehaviorRelay.accept(epImage)
        self.epDescriptionBehaviorRelay.accept(epDescription)
    }
    
    /// Transform EpisodeDetail array to PlayerDetails array.
    /// - Parameter episodeDetails: EpisodeDetail array.
    /// - Returns: PlayerDetail array.
    private func transformToPlayerDetails(episodeDetails:[EpisodeDetail]) -> [PlayerDetail] {
        let playerDetails = episodeDetails.map {
            PlayerDetail(epTitle: $0.epTitle,
                         epImageUrl: $0.epImageUrl,
                         audioLinkUrl: $0.audioLinkUrl)
        }
        return playerDetails
    }
    
}

// MARK: - EpisodePageViewModelType

extension EpisodePageViewModel: EpisodePageViewModelType {
	var input: EpisodePageViewModelInput { self }
	var output: EpisodePageViewModelOutput { self }
}

// MARK: - EpisodePageViewModelInput

extension EpisodePageViewModel: EpisodePageViewModelInput {
	/// Create PlayerPageViewModel.
	/// - Returns: The view model prepare for next page.
	func createPlayerPageViewModel() -> PlayerPageViewModel {
		let playerDetails = transformToPlayerDetails(episodeDetails: episodeDetails)
		let playerPageViewModel = PlayerPageViewModel(playerDetails: playerDetails, currentEpisodeIndex: currentEpisodeIndex)
		return playerPageViewModel
	}
}

// MARK: - EpisodePageViewModelOutput

extension EpisodePageViewModel: EpisodePageViewModelOutput {
	var podcastTitle: Observable<String> { podcastTitleBehaviorRelay.asObservable() }
	var epTitle: Observable<String> { epTitleBehaviorRelay.asObservable() }
	var epImageUrl: Observable<String> { epImageUrlBehaviorRelay.asObservable() }
	var epDescription: Observable<String> { epDescriptionBehaviorRelay.asObservable() }
}
