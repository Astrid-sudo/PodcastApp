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

class EpisodePageViewModel {
    
    // MARK: - properties be observed
    
	let podcastTitle = BehaviorRelay<String>(value: "")
	let epTitle = BehaviorRelay<String>(value: "")
	let epImageUrl = BehaviorRelay<String>(value: "")
	let epDescription = BehaviorRelay<String>(value: "")
	
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
    func parseFeedItem() {
        guard episodeDetails.count > currentEpisodeIndex else { return }
        let currentEpisodeDetail = episodeDetails[currentEpisodeIndex]
        guard let podcastTitile = currentEpisodeDetail.podcastTitile,
              let epTitle = currentEpisodeDetail.epTitle,
              let epImage = currentEpisodeDetail.epImageUrl ,
              let epDescription = currentEpisodeDetail.epDescription else { return }
		self.podcastTitle.accept(podcastTitile)
        self.epTitle.accept(epTitle)
        self.epImageUrl.accept(epImage)
        self.epDescription.accept(epDescription)
    }
    
    /// Create PlayerPageViewModel.
    /// - Returns: The view model prepare for next page.
    func createPlayerPageViewModel() -> PlayerPageViewModel {
        let playerDetails = transformToPlayerDetails(episodeDetails: episodeDetails)
        let playerPageViewModel = PlayerPageViewModel(playerDetails: playerDetails, currentEpisodeIndex: currentEpisodeIndex)
        return playerPageViewModel
    }
    
    /// Transform EpisodeDetail array to PlayerDetails array.
    /// - Parameter episodeDetails: EpisodeDetail array.
    /// - Returns: PlayerDetail array.
    func transformToPlayerDetails(episodeDetails:[EpisodeDetail]) -> [PlayerDetail] {
        let playerDetails = episodeDetails.map {
            PlayerDetail(epTitle: $0.epTitle,
                         epImageUrl: $0.epImageUrl,
                         audioLinkUrl: $0.audioLinkUrl)
        }
        return playerDetails
    }
    
}
