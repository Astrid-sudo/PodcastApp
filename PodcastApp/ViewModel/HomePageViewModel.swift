//
//  HomePageViewModel.swift
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

import UIKit

struct EpisodeDetail {
    let podcastTitile: String?
    let epTitle: String?
    let epImageUrl: String?
    let epDescription: String?
    let audioLinkUrl: String?
}

class HomePageViewModel: NSObject {
    
    // MARK: - properties be observed

    let networkAvailable: Box<Bool> = Box(true)
    let rssFeedItems: Box<[RssItem]> = Box([RssItem]())
    var homeImageUrlString: Box<String> = Box("")
    let episodePageViewModel: Box<EpisodePageViewModel> = Box(EpisodePageViewModel())

    // MARK: - properties
    
    private(set) lazy var networkManager: NetworkManager = {
        return NetworkManager()
    }()
    
    private lazy var rssHelper: RssHelper = {
        return RssHelper()
    }()
    var reeFeedUrl = "https://feeds.soundcloud.com/users/soundcloud:users:322164009/sounds.rss"
    var originRssFeedItems = [RssItem]()
    var rssFeedTitle: String?
    var feedParedFinished = false
    
    // MARK: - init
    
    override init() {
        super.init()
        checkNetwork(connectionHandler: connectionHandler, noConnectionHandler: noConnectionHandler)
        rssHelper.delegate = self
        rssHelper.parsefeed(withUrlString: reeFeedUrl)
    }
    
    // MARK: - method
    
    /// Fetch and parse RssFeed if parsing haven't finish.
    func continueParseRssFeed() {
        if !feedParedFinished {
            rssHelper.parsefeed(withUrlString: reeFeedUrl)
        }
    }
    
    /// Gathering data to create an EpisodeDetail array.
    /// - Parameters:
    ///   - rssFeedItems: Rss item array fetched from RSS Feed url.
    ///   - podcastTitle: Podcast title fetched from RSS Feed url.
    /// - Returns: EpisodeDetail array
    func transformToEpisodeDetails(rssFeedItems:[RssItem],
                                   podcastTitle: String) -> [EpisodeDetail] {
        let episodeDetails = rssFeedItems.map {
            EpisodeDetail(podcastTitile: podcastTitle,
                          epTitle: $0.rssTitle,
                          epImageUrl: $0.rssEpImageUrl,
                          epDescription: $0.rssDescription,
                          audioLinkUrl: $0.rssAudioUrl)
        }
        return episodeDetails
    }
    
    /// Make pubDate from "EEE, d MMM yyyy" to "yyyy/MM/d" in RssItem array.
    /// - Parameter items: An RssItem array.
    /// - Returns: An RssItem array with "yyyy/MM/d" format pubDate.
    func transformItemsDate(items:[RssItem]) -> [RssItem] {
        let newItems = items.map{
            RssItem(rssTitle: $0.rssTitle,
                    initWithRssDescription: $0.rssDescription,
                    initWithRssPubDate: convertDate(dateString: $0.rssPubDate),
                    initWithAudioUrl: $0.rssAudioUrl, initWithEpImageUrl: $0.rssEpImageUrl)
        }
        return newItems
    }
    
    /// Convert date string from "EEE, d MMM yyyy HH:mm:ss +0000" to "yyyy/MM/d"
    /// - Parameter dateString: Date string in "EEE, d MMM yyyy HH:mm:ss +0000".
    /// - Returns: Date string in "yyyy/MM/d".
    func convertDate(dateString: String) -> String {
        let string = String(dateString.dropLast(21))
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "EEE, d MMM yyyy"
        if let date = dateFormatter.date(from: string) {
            dateFormatter.dateFormat = "yyyy/MM/d"
            let ss = dateFormatter.string(from: date)
            return ss
        }
        return ""
    }
    
}

// MARK: - RssHelperDelegate

extension HomePageViewModel: RssHelperDelegate {
    
    func suceededFetchRss(_ rssItems: [Any], infoTitle: String, infoImage: String) {
        feedParedFinished = true
        let rssItemArray = rssItems.compactMap({ $0 as? RssItem})
        self.originRssFeedItems = rssItemArray
        self.rssFeedItems.value = transformItemsDate(items: originRssFeedItems)
        self.rssFeedTitle = String(infoTitle)
        homeImageUrlString.value = infoImage
    }
    
    func failedFetchRss(_ error: Error) {
        print("Failed fetch rss \(error)")
    }

}

// MARK: - NetworkCheckable

extension HomePageViewModel: NetworkCheckable {

    private func connectionHandler() {
        DispatchQueue.main.async {
                self.continueParseRssFeed()
            self.networkAvailable.value = true
        }
    }
    
    private func noConnectionHandler() {
        DispatchQueue.main.async {
            self.networkAvailable.value = false
        }
    }
    
}


