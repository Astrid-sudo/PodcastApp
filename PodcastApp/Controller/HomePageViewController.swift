//
//  HomePageViewController.swift
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

import UIKit

class HomePageViewController: UIViewController {
    
    // MARK: - properties
    
    let homePageViewModel = HomePageViewModel()
    
    // MARK: - UI properties
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: CGRect(), style: .grouped)
        table.backgroundColor = .clear
        table.dataSource = self
        table.delegate = self
        table.allowsSelection = true
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.register(HomePageTableViewCell.self, forCellReuseIdentifier: HomePageTableViewCell.reuseIdentifier)
        table.register(HomePageTableViewHeader.self, forHeaderFooterViewReuseIdentifier: HomePageTableViewHeader.reuseIdentifier)
        return table
    }()
    
    var noNetworkAlert: UIAlertController?
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setTableView()
        binding()
    }
    
    // MARK: - config UI method
    
    func setTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - method
    
    func binding() {
        
        homePageViewModel.networkAvailable.bind { [weak self] bool in
            guard let self = self else { return }
            if bool {
                if let noNetworkAlert = self.noNetworkAlert {
                    self.dismissAlert(noNetworkAlert, completion: nil)
                }
            } else {
                self.noNetworkAlert = self.popAlert(title: "無網路連線", message: "請檢查您的網路連線")
            }
        }
        
        homePageViewModel.rssFeedItems.bind { [weak self] _ in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
        
        homePageViewModel.homeImage.bind { [weak self] _ in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
        
        homePageViewModel.episodePageViewModel.bind { [weak self] episodePageViewModel in
            guard let self = self else { return }
            if !episodePageViewModel.episodeDetails.isEmpty {
                self.pushToEpisodePage(episodePageViewModel: episodePageViewModel)
            }
        }
    }
    
    func prepareForEpisodePage(image: UIImage?, episodeIndex: Int) {
        guard let rssFeedTitle = homePageViewModel.rssFeedTitle else { return }
        let episodeDetails = homePageViewModel.transformToEpisodeDetails(rssFeedItems: homePageViewModel.rssFeedItems.value, podcastTitle: rssFeedTitle, epImage: image)
        let episodeViewModel = EpisodePageViewModel(episodeDetails: episodeDetails, currentEpisodeIndex: episodeIndex)
        self.homePageViewModel.episodePageViewModel.value = episodeViewModel
    }
    
    func pushToEpisodePage(episodePageViewModel: EpisodePageViewModel) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let episodePageViewController = storyboard.instantiateViewController(withIdentifier: EpisodePageViewController.reuseIdentifier) as? EpisodePageViewController else { return }
        episodePageViewController.episodePageViewModel = episodePageViewModel
        navigationController?.pushViewController(episodePageViewController, animated: true)
    }

}

// MARK: - UITableViewDataSource

extension HomePageViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        homePageViewModel.rssFeedItems.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomePageTableViewCell.reuseIdentifier) as? HomePageTableViewCell else { return UITableViewCell()}
        
        if homePageViewModel.imageInCache(indexPath: indexPath) {
            cell.configCell(image: homePageViewModel.cacheEpImages[indexPath.row],
                            epTitle: homePageViewModel.rssFeedItems.value[row].rssTitle,
                            updateDate: homePageViewModel.rssFeedItems.value[row].rssPubDate)
        } else {
            homePageViewModel.downloadToCache(indexPath: indexPath) { [weak self] image in
                guard let self = self else { return }
                cell.configCell(image: image,
                                epTitle: self.homePageViewModel.rssFeedItems.value[row].rssTitle,
                                updateDate: self.homePageViewModel.rssFeedItems.value[row].rssPubDate)
            }
        }
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension HomePageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HomePageTableViewHeader.reuseIdentifier) as? HomePageTableViewHeader else { return UIView()}
        let image = homePageViewModel.homeImage.value
        headerView.configImage(image: image)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 250
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if homePageViewModel.imageInCache(indexPath: indexPath) {
            prepareForEpisodePage(image: homePageViewModel.cacheEpImages[indexPath.row], episodeIndex: indexPath.row)
        } else {
            homePageViewModel.downloadToCache(indexPath: indexPath) { [weak self] image in
                guard let self = self else { return }
                self.prepareForEpisodePage(image: image, episodeIndex: indexPath.row)
            }
        }
    }
    
}

