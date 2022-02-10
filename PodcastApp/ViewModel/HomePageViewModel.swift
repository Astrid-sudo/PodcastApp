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
    
    let rssFeedModel = RssFeedModel()
    let rssFeedItems: Box<[RSSFeedItem]> = Box([RSSFeedItem]())
    var rssFeedTitle: String?
    var homeImageURL: URL? 
    
    
    override init() {
        super.init()
        rssFeedModel.fetchRss { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let rssFeed):
                self.rssFeedItems.value = rssFeed.items!
                self.rssFeedTitle = rssFeed.title
                self.homeImageURL = URL(string: (rssFeed.iTunes?.iTunesImage?.attributes?.href)!)
            case .failure(let error):
                print(error)
            }
        }
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
        if let urlString = rssFeedItems.value[row].iTunes?.iTunesImage?.attributes?.href {
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    epImage = UIImage(data: data)
                }
            }
        }
        
        cell.configCell(image: epImage,
                        epTitle: rssFeedItems.value[row].title,
                        updateDate: rssFeedItems.value[row].pubDate?.ISO8601Format())
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
        
    }

}
