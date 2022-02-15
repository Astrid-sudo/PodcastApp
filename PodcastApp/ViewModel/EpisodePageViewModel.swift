//
//  EpisodePageViewModel.swift
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

import UIKit

struct PlayerDetail {
    let epTitle: String?
    let epImageUrl: String?
    let audioLinkUrl: String?
}

class EpisodePageViewModel {
    
    // MARK: - properties be observed
    
    let podcastTitle: Box<String> = Box("")
    let epTitle: Box<String> = Box("")
    let epImageUrl: Box<String> = Box("")
    let epDescription: Box<String> = Box("")
    
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
        
        self.podcastTitle.value = podcastTitile
        self.epTitle.value = epTitle
        self.epImageUrl.value = epImage
        self.epDescription.value = epDescription
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
