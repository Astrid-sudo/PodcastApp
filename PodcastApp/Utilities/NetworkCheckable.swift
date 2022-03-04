//
//  NetworkCheckable.swift
//  PodcastApp
//
//  Created by Astrid on 2022/2/15.
//

import Network

class NetworkManager {
    
    static let shared = NetworkManager()
    
    let monitor = NWPathMonitor()
    
    private init() {}
}

protocol NetworkCheckable {}

extension NetworkCheckable {
    
    var networkMonitor: NWPathMonitor {
        return NetworkManager.shared.monitor
    }
    
    /// Check whether there is network connection.
    /// - Parameters:
    ///   - connectionHandler: The closure will be executed when connection resume .
    ///   - noConnectionHandler: The closure will be executed if there is no network connection.
    func checkNetwork(connectionHandler: @escaping ()->Void,
                      noConnectionHandler: @escaping ()->Void) {
        networkMonitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                connectionHandler()
            } else {
                noConnectionHandler()
            }
        }
        networkMonitor.start(queue: DispatchQueue.global())
    }
    
}

