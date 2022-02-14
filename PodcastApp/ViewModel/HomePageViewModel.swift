//
//  HomePageViewModel.swift
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

import UIKit
import FeedKit

struct EpisodeDetail {
    let podcastTitile: String?
    let epTitle: String?
    let epImage: UIImage?
    let epDescription: String?
    let audioLinkUrl: String?
}

class HomePageViewModel: NSObject {
    
    let rssHelper = RssHelper()
    let rssFeedItems: Box<[RssItem]> = Box([RssItem]())
    var rssFeedTitle: String?
    var homeImageUrlString: String?
    
    var homeImage: UIImage?
    var epImage: UIImage?
    
    var episodePageViewModel: Box<EpisodePageViewModel> = Box(EpisodePageViewModel())
    
    // MARK: - init
    
    override init() {
        super.init()
        rssHelper?.delegate = self
        rssHelper?.parsefeed(withUrlString: "https://feeds.soundcloud.com/users/soundcloud:users:322164009/sounds.rss")
    }
    
    // MARK: - method
    
    func transformToEpisodeDetails(rssFeedItems:[RssItem],
                                   podcastTitle: String,
                                   epImage: UIImage?) -> [EpisodeDetail] {
        
        let episodeDetails = rssFeedItems.map {
            EpisodeDetail(podcastTitile: podcastTitle,
                          epTitle: $0.rssTitle,
                          epImage: epImage,
                          epDescription: $0.rssDescription,
                          audioLinkUrl: $0.rssAudioUrl)
        }
        return episodeDetails
    }
    
    func fetchImage(urlString: String?) -> UIImage? {
        var myImage: UIImage?
        if let string = urlString {
            if let homeImageURL = URL(string: string) {
                if let data = try? Data(contentsOf: homeImageURL) {
                    myImage = UIImage(data: data)
                }
            }
        }
        return myImage
    }
    
}

// MARK: - RssHelperDelegate

extension HomePageViewModel: RssHelperDelegate {
    
    func suceededFetchRss(_ rssItems: [Any], infoTitle: String, infoImage: String) {
        let rssItemArray = rssItems.compactMap({ $0 as? RssItem})
        self.rssFeedItems.value = rssItemArray
        self.rssFeedTitle = String(infoTitle)
        homeImageUrlString = infoImage
        homeImage = fetchImage(urlString: self.homeImageUrlString)
        epImage = fetchImage(urlString: rssFeedItems.value[0].rssEpImageUrl)
    }
    
    func failedFetchRss() {
    }
    
    
}
