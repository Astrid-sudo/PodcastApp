//
//  RssFeedModel.swift
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

import Foundation
import FeedKit

class RssFeedModel: NSObject, XMLParserDelegate {
    
    override init() {
        super.init()
    }
    
    func fetchRss(completion: @escaping(Result<RSSFeed, Error>)->Void) {
        parseXML(completion: completion)
    }
    
    let url = URL(string: "https://feeds.soundcloud.com/users/soundcloud:users:322164009/sounds.rss")!

    private lazy var parser: FeedParser = {
        let parser = FeedParser(URL: url)
        return parser
    }()

    func parseXML(completion: @escaping(Result<RSSFeed, Error>)->Void)  {
        // Parse asynchronously, not to block the UI.
        parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
            // Do your thing, then back to the Main thread
            DispatchQueue.main.async { [self] in
                // ..and update the UI
                switch result {
                case .success(let feed):
                    
                    // Grab the parsed feed directly as an optional rss, atom or json feed object
                    feed.rssFeed
                    
                    // Or alternatively...
                    switch feed {
                    case .atom(let feed): print("This is atom\(feed)")  // Atom Syndication Format Feed Model
                    case .rss(let feed):
                        let a = feed
                        completion(.success(feed))
                    case .json(let feed): print(feed)  // JSON Feed Model
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

}


