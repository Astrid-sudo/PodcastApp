//
//  HomePageViewModel.swift
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

import UIKit
import RxSwift
import RxRelay

struct EpisodeDetail {
    let podcastTitile: String?
    let epTitle: String?
    let epImageUrl: String?
    let epDescription: String?
    let audioLinkUrl: String?
}

protocol HomePageViewModelType {
	var input: HomePageViewModelInput { get }
	var output: HomePageViewModelOutput { get }
}

protocol HomePageViewModelInput { // Actions 外面的人要叫HomePageViewModel做的事
	func transformToEpisodeDetails(rssFeedItems:[RssItem], podcastTitle: String) -> [EpisodeDetail]
	func prepareForEpisodePage(episodePageViewModel: EpisodePageViewModel)
}

protocol HomePageViewModelOutput { // UI HomePageViewModel要給外界觀察的值
	var networkAvailable: Observable<Bool> { get }
	var rssFeedItems: Observable<[RssItem]> { get }
	var homeImageUrlString: Observable<String> { get }
	var episodePageViewModel: Observable<EpisodePageViewModel> { get }
	var homeImageUrlPureString: String { get }
	var rssFeedPureItems: [RssItem] { get }
}

class HomePageViewModel: NSObject {
    
    // MARK: - properties would be assigned value and be observed

	private let rssFeedItemsBehaviorRelay = BehaviorRelay<[RssItem]>(value: [])
	private let homeImageUrlStringBehaviorRelay = BehaviorRelay<String>(value: "")
	private let episodePageViewModelBehaviorRelay = BehaviorRelay<EpisodePageViewModel>(value: EpisodePageViewModel())
    private let networkAvailableSubject = PublishSubject<Bool>()

	var homeImageUrlPureString: String { homeImageUrlStringBehaviorRelay.value }
	var rssFeedPureItems: [RssItem] { rssFeedItemsBehaviorRelay.value }

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
    private func continueParseRssFeed() {
        if !feedParedFinished {
            rssHelper.parsefeed(withUrlString: reeFeedUrl)
        }
    }
    
    /// Make pubDate from "EEE, d MMM yyyy" to "yyyy/MM/d" in RssItem array.
    /// - Parameter items: An RssItem array.
    /// - Returns: An RssItem array with "yyyy/MM/d" format pubDate.
    private func transformItemsDate(items:[RssItem]) -> [RssItem] {
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
    private func convertDate(dateString: String) -> String {
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

// MARK: - HomePageViewModelType

extension HomePageViewModel: HomePageViewModelType {
	var input: HomePageViewModelInput { self }
	var output: HomePageViewModelOutput { self }
}

// MARK: - HomePageViewModelInput

extension HomePageViewModel: HomePageViewModelInput {

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

	func prepareForEpisodePage(episodePageViewModel: EpisodePageViewModel) {
		episodePageViewModelBehaviorRelay.accept(episodePageViewModel)
	}

}

// MARK: - HomePageViewModelOutput

extension HomePageViewModel: HomePageViewModelOutput {
	var networkAvailable: Observable<Bool> { networkAvailableSubject.asObservable() }
	var rssFeedItems: Observable<[RssItem]> { rssFeedItemsBehaviorRelay.asObservable() }
	var homeImageUrlString: Observable<String> { homeImageUrlStringBehaviorRelay.asObservable() }
	var episodePageViewModel: Observable<EpisodePageViewModel> { episodePageViewModelBehaviorRelay.asObservable() }
}

// MARK: - RssHelperDelegate

extension HomePageViewModel: RssHelperDelegate {
    
    func suceededFetchRss(_ rssItems: [Any], infoTitle: String, infoImage: String) {
        feedParedFinished = true
        let rssItemArray = rssItems.compactMap({ $0 as? RssItem})
        self.originRssFeedItems = rssItemArray
		self.rssFeedItemsBehaviorRelay.accept(transformItemsDate(items: originRssFeedItems))
        self.rssFeedTitle = String(infoTitle)
		homeImageUrlStringBehaviorRelay.accept(infoImage)
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
			self.networkAvailableSubject.onNext(true)
        }
    }
    
    private func noConnectionHandler() {
        DispatchQueue.main.async {
			self.networkAvailableSubject.onNext(false)
        }
    }
    
}


