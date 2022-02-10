//
//  PlayerPageViewModel.swift
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

import UIKit
import CoreMedia

class PlayerPageViewModel {
    
    // MARK: - properties be observed
    
    let epTitle: Box<String> = Box("")
    let epImage: Box<UIImage> = Box(UIImage())
    let playButtonType: Box<PlayButtonType> = Box(.play)
    let playProgress: Box<Float> = Box(.zero)
    let currentTime = Box("")
    let duration = Box("")
    
    // MARK: - properties
    
    var playerDetails = [PlayerDetail]()
    var currentEpisodeIndex = 0
    var audioLink = ""
    
    // MARK: - init / deinit
    
    init(playerDetails: [PlayerDetail], currentEpisodeIndex: Int) {
        self.playerDetails = playerDetails
        self.currentEpisodeIndex = currentEpisodeIndex
        parsePlayerDetail()
    }
    
    init() {}
    
    deinit {
        print("PlayerPageModel Deinit")
    }
    
    // MARK: - method
    
    func parsePlayerDetail() {
        guard playerDetails.count > currentEpisodeIndex else { return }
        let currentPlayerDetail = playerDetails[currentEpisodeIndex]
        guard let epTitle = currentPlayerDetail.epTitle,
              let epImage = currentPlayerDetail.epImage,
              let audioLinkUrl = currentPlayerDetail.audioLinkUrl else { return }
        
        self.epTitle.value = epTitle
        self.epImage.value = epImage
        self.audioLink = audioLinkUrl
    }
    
}
