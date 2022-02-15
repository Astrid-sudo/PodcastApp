//
//  ReuseID.swift
//  PodcastApp
//
//  Created by Astrid on 2022/2/15.
//

import Foundation

protocol ReuseID {}

extension ReuseID {
    static var reuseIdentifier: String {
        String(describing: self)
    }
}

