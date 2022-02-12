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
    var homeImageURL: URL?
    
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
                                   epImage: UIImage) -> [EpisodeDetail] {
        
        let episodeDetails = rssFeedItems.map {
            EpisodeDetail(podcastTitile: podcastTitle,
                          epTitle: $0.rssTitle as String,
                          epImage: epImage,
                          epDescription: $0.rssDescription as String,
                          audioLinkUrl: $0.rssAudioUrl)
        }
        return episodeDetails
    }
    
}

// MARK: - UITableViewDataSource

extension HomePageViewModel: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rssFeedItems.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomePageTableViewCell.reuseIdentifier) as? HomePageTableViewCell else { return UITableViewCell()}
        var epImage: UIImage?
            if let url = URL(string: rssFeedItems.value[row].rssEpImageUrl) {
                if let data = try? Data(contentsOf: url) {
                    epImage = UIImage(data: data)
                }
            }
        
        cell.configCell(image: epImage,
                        epTitle: rssFeedItems.value[row].rssTitle as String,
                        updateDate: rssFeedItems.value[row].rssPubDate as String)
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension HomePageViewModel: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var myImage: UIImage?
        if let homeImageURL = homeImageURL {
            if let data = try? Data(contentsOf: homeImageURL) {
                myImage = UIImage(data: data)
            }
        }
        
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HomePageTableViewHeader.reuseIdentifier) as? HomePageTableViewHeader else { return UIView()}
        headerView.configImage(image: myImage)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 250
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let row = indexPath.row
        
        var myImage: UIImage?
        if let homeImageURL = URL(string: rssFeedItems.value[row].rssEpImageUrl) {
            if let data = try? Data(contentsOf: homeImageURL) {
                myImage = UIImage(data: data)
            }
        }
        
        guard let myImage = myImage,
        let rssFeedTitle = rssFeedTitle else { return }
        let episodeDetails = transformToEpisodeDetails(rssFeedItems: rssFeedItems.value, podcastTitle: rssFeedTitle, epImage: myImage)
        
        let episodeViewModel = EpisodePageViewModel(episodeDetails: episodeDetails, currentEpisodeIndex: row)
        self.episodePageViewModel.value = episodeViewModel
    }

}

// MARK: - RssHelperDelegate

extension HomePageViewModel: RssHelperDelegate {
    
    func suceededFetchRss(_ rssItems: [Any], infoTitle: NSMutableString, infoImage: String) {
        let rssItemArray = rssItems.compactMap({ $0 as? RssItem})
        self.rssFeedItems.value = rssItemArray
        self.rssFeedTitle = String(infoTitle)
        self.homeImageURL = URL(string: infoImage)
    }
    
    func failedFetchRss() {
    }
    
    
}
