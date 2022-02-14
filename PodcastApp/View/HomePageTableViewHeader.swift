//
//  HomePageTableViewHeader.swift
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

import UIKit

class HomePageTableViewHeader: UITableViewHeaderFooterView {
    
    // MARK: - properties
    
    static let reuseIdentifier = String(describing: HomePageTableViewHeader.self)
    
    // MARK: - UI properties
    
    private lazy var headerImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    // MARK: - init
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setHeaderImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Method
    
    private func setHeaderImage() {
        contentView.addSubview(headerImage)
        headerImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configImage(image: UIImage?) {
        headerImage.image = image
    }
    
}

