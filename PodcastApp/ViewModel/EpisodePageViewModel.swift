//
//  EpisodePageViewModel.swift
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

import UIKit
import FeedKit

class EpisodePageViewModel {
    
    // MARK: - properties be observed
    
    let podcastTitle: Box<String> = Box("")
    let epTitle: Box<String> = Box("")
    let epImage: Box<UIImage> = Box(UIImage())
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
    
    deinit {
        print("EpisodePageViewModel Deinit")
    }
    
    // MARK: - method
    
    func parseFeedItem() {
        guard episodeDetails.count > currentEpisodeIndex else { return }
        let currentEpisodeDetail = episodeDetails[currentEpisodeIndex]
        guard let podcastTitile = currentEpisodeDetail.podcastTitile,
              let epTitle = currentEpisodeDetail.epTitle,
              let epImage = currentEpisodeDetail.epImage,
              let epDescription = currentEpisodeDetail.epDescription else { return }
        
        self.podcastTitle.value = podcastTitile
        self.epTitle.value = epTitle
        self.epImage.value = epImage
        self.epDescription.value = epDescription
    }

    init() {}
    
}
