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
    var originRssFeedItems = [RssItem]()
    let rssFeedItems: Box<[RssItem]> = Box([RssItem]())
    var rssFeedTitle: String?
    var homeImageUrlString: String?
    
    var cacheEpImages: [Int: UIImage] = [:]
    var homeImage: Box<UIImage> = Box(UIImage())

    var episodePageViewModel: Box<EpisodePageViewModel> = Box(EpisodePageViewModel())
    
    // MARK: - init
    
    override init() {
        super.init()
        rssHelper?.delegate = self
        rssHelper?.parsefeed(withUrlString: "https://feeds.soundcloud.com/users/soundcloud:users:322164009/sounds.rss")
    }
    
    // MARK: - method
    
    /// Gathering data to create an EpisodeDetail array.
    /// - Parameters:
    ///   - rssFeedItems: Rss item array fetched from RSS Feed url.
    ///   - podcastTitle: Podcast title fetched from RSS Feed url.
    ///   - epImage: EpImage fetched from RSS Feed url.
    /// - Returns: EpisodeDetail array
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
    
    /// Download image with url string and pass the image out by closure.
    /// - Parameters:
    ///   - urlString: Image url string.
    ///   - completion: The closure will be execute after finishing download image.
    func downloadImage(urlString: String, completion: @escaping(UIImage) -> Void) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
    
    /// Download image with url string and pass the image out by closure and store in cache dictionary.
    /// - Parameters:
    ///   - indexPath: The index of the image in rss feed data.
    ///   - completion: The closure will be execute after finishing download image.
    func downloadToCache(indexPath: IndexPath, completion: @escaping(UIImage) -> Void) {
        let urlString = rssFeedItems.value[indexPath.row].rssEpImageUrl
        downloadImage(urlString: urlString) { [weak self] image in
            guard let self = self else { return }
            self.cacheEpImages[indexPath.row] = image
            completion(image)
        }
    }
    
    /// Check whether an image is already in cache dictionary.
    /// - Parameters:
    /// - indexPath: The index of the image in rss feed data.
    /// - Returns: True if the image in already in the cache dictionary, vice versa.
    func imageInCache(indexPath: IndexPath) -> Bool {
        return cacheEpImages[indexPath.row] != nil
    }
    
}

// MARK: - RssHelperDelegate

extension HomePageViewModel: RssHelperDelegate {
    
    func suceededFetchRss(_ rssItems: [Any], infoTitle: String, infoImage: String) {
        let rssItemArray = rssItems.compactMap({ $0 as? RssItem})
        self.originRssFeedItems = rssItemArray
        self.rssFeedItems.value = transformItemsDate(items: originRssFeedItems)
        self.rssFeedTitle = String(infoTitle)
        homeImageUrlString = infoImage
        if let imageUrl = homeImageUrlString {
            downloadImage(urlString: imageUrl) { [weak self] image in
                guard let self = self else { return }
                self.homeImage.value = image
            }
        }
    }
    
    func failedFetchRss() {
    }
    
    
}
