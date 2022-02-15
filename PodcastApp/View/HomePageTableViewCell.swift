//
//  HomePageTableViewCell.swift
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

import UIKit

class HomePageTableViewCell: UITableViewCell {
    
    // MARK: - properties
    
    static let reuseIdentifier = String(describing: HomePageTableViewCell.self)
    
    // MARK: - UI properties
    
    private lazy var theImageView: UIImageView = {
        let image = UIImageView()
        image.layer.masksToBounds = true
        return image
    }()
    
    private lazy var epTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = UIFont(name: "PingFang TC", size: 12)
        return label
    }()
    
    private lazy var updateDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .left
        label.font = UIFont(name: "PingFang TC", size: 12)
        return label
    }()
    
    let padding: CGFloat = 16
    
    //MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        setImageView()
        setEpTitleLabel()
        setUpdateDateLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI method
    
    private func setImageView() {
        contentView.addSubview(theImageView)
        theImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            theImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            theImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            theImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            theImageView.heightAnchor.constraint(equalToConstant: 4.5 * padding),
            theImageView.widthAnchor.constraint(equalTo: theImageView.heightAnchor)
        ])
    }
    
    private func setEpTitleLabel() {
        contentView.addSubview(epTitleLabel)
        epTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            epTitleLabel.leadingAnchor.constraint(equalTo: theImageView.trailingAnchor, constant: padding),
            epTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            epTitleLabel.topAnchor.constraint(equalTo: theImageView.topAnchor)
        ])
    }
    
    private func setUpdateDateLabel() {
        contentView.addSubview(updateDateLabel)
        updateDateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            updateDateLabel.leadingAnchor.constraint(equalTo: theImageView.trailingAnchor, constant: padding),
            updateDateLabel.bottomAnchor.constraint(equalTo: theImageView.bottomAnchor)
        ])
    }
    
    func configCell(image: UIImage?, epTitle: String?, updateDate: String?) {
        theImageView.image = image
        epTitleLabel.text = epTitle
        updateDateLabel.text = updateDate
    }
    
    func displayImage(image: UIImage) {
        theImageView.image = image
    }

}

