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
        homePageViewModel.rssFeedItems.bind { [weak self] _ in
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
    
    func pushToEpisodePage(episodePageViewModel: EpisodePageViewModel) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let episodePageViewController = storyboard.instantiateViewController(withIdentifier: EpisodePageViewController.reuseIdentifier) as? EpisodePageViewController else { return }
        episodePageViewController.episodePageViewModel = episodePageViewModel
        navigationController?.pushViewController(episodePageViewController, animated: true)
    }
    
    private func cellDownloadWithUrlSession(at indexPath: IndexPath) {
        guard let url = URL(string: homePageViewModel.rssFeedItems.value[indexPath.row].rssEpImageUrl) else { return }
        URLSession.shared.dataTask(with: url) {
        [weak self] data, response, error in
        guard let self = self,
          let data = data,
          let image = UIImage(data: data) else {
            return
        }

        DispatchQueue.main.async {
            if let cell = self.tableView.cellForRow(at: indexPath) as? HomePageTableViewCell {
            cell.displayImage(image: image)
          }
        }
      }.resume()
    }
    
    private func nextDownloadWithUrlSession(at indexPath: IndexPath, nextViewModel: EpisodePageViewModel) {
        guard let url = URL(string: homePageViewModel.rssFeedItems.value[indexPath.row].rssEpImageUrl),
              let rssFeedTitle = homePageViewModel.rssFeedTitle else { return }
        URLSession.shared.dataTask(with: url) {
        [weak self] data, response, error in
        guard let self = self,
          let data = data,
          let image = UIImage(data: data) else {
            return
        }
        DispatchQueue.main.async {
            let episodeDetails = self.homePageViewModel.transformToEpisodeDetails(rssFeedItems: self.homePageViewModel.rssFeedItems.value, podcastTitle: rssFeedTitle, epImage: image)
            let episodeViewModel = EpisodePageViewModel(episodeDetails: episodeDetails, currentEpisodeIndex: indexPath.row)
            self.homePageViewModel.episodePageViewModel.value = episodeViewModel
        }
      }.resume()
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
        let pubDate = homePageViewModel.rssFeedItems.value[row].rssPubDate
        cell.configCell(image: nil,
                        epTitle: homePageViewModel.rssFeedItems.value[row].rssTitle,
                        updateDate: pubDate)
        cellDownloadWithUrlSession(at: indexPath)
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension HomePageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var myImage: UIImage?
        if let string = homePageViewModel.homeImageUrlString {
            if let homeImageURL = URL(string: string) {
                if let data = try? Data(contentsOf: homeImageURL) {
                    myImage = UIImage(data: data)
                }
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
        guard let rssFeedTitle = homePageViewModel.rssFeedTitle else { return }
        let episodeDetails = homePageViewModel.transformToEpisodeDetails(rssFeedItems: homePageViewModel.rssFeedItems.value, podcastTitle: rssFeedTitle, epImage: nil)
        let episodeViewModel = EpisodePageViewModel(episodeDetails: episodeDetails, currentEpisodeIndex: row)
        nextDownloadWithUrlSession(at: indexPath, nextViewModel: episodeViewModel)
    }

}

