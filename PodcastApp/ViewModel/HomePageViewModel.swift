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
    
    func transformItemsDate(items:[RssItem]) -> [RssItem] {
        let newItems = items.map{
            RssItem(rssTitle: $0.rssTitle,
                    initWithRssDescription: $0.rssDescription,
                    initWithRssPubDate: convertDate(dateString: $0.rssPubDate),
                    initWithAudioUrl: $0.rssAudioUrl, initWithEpImageUrl: $0.rssEpImageUrl)
        }
        return newItems
    }
    
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
    
    func downloadToCache(indexPath: IndexPath, completion: @escaping(UIImage) -> Void) {
        let urlString = rssFeedItems.value[indexPath.row].rssEpImageUrl
        downloadImage(urlString: urlString) { [weak self] image in
            guard let self = self else { return }
            self.cacheEpImages[indexPath.row] = image
            completion(image)
        }
    }
    
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
