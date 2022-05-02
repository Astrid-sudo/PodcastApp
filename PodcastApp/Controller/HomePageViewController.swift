//
//  HomePageViewController.swift
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

import UIKit
import RxSwift

class HomePageViewController: UIViewController {
    
    // MARK: - properties
    
    let homePageViewModel = HomePageViewModel()
	let bag = DisposeBag()
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
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

		homePageViewModel.output.networkAvailable.subscribe(onNext: { available in
			if available {
				if let noNetworkAlert = self.noNetworkAlert {
					self.dismissAlert(noNetworkAlert, completion: nil)
				}
			} else {
				self.noNetworkAlert = self.popAlert(title: "無網路連線", message: "請檢查您的網路連線")
			}
		}).disposed(by: bag)
        
		homePageViewModel.output.rssFeedItems.subscribe(onNext: { _ in
			self.tableView.reloadData()
		}).disposed(by: bag)

		homePageViewModel.output.homeImageUrlString.subscribe(onNext: { _ in
			self.tableView.reloadData()
		}).disposed(by: bag)
        
		homePageViewModel.output.episodePageViewModel.subscribe(onNext: { episodePageViewModel in
			if !episodePageViewModel.episodeDetails.isEmpty {
				self.pushToEpisodePage(episodePageViewModel: episodePageViewModel)
			}
		}).disposed(by: bag)

    }
    
    func prepareForEpisodePage(episodeIndex: Int) {
        guard let rssFeedTitle = homePageViewModel.rssFeedTitle else { return }
		let episodeDetails = homePageViewModel.input.transformToEpisodeDetails(rssFeedItems: homePageViewModel.output.rssFeedItems.value, podcastTitle: rssFeedTitle)
        let episodeViewModel = EpisodePageViewModel(episodeDetails: episodeDetails, currentEpisodeIndex: episodeIndex)
		self.homePageViewModel.output.episodePageViewModel.accept(episodeViewModel)
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
        
		cell.configCell(imageURLString: homePageViewModel.output.rssFeedItems.value[row].rssEpImageUrl , epTitle: homePageViewModel.output.rssFeedItems.value[row].rssTitle, updateDate: homePageViewModel.output.rssFeedItems.value[row].rssPubDate)
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension HomePageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HomePageTableViewHeader.reuseIdentifier) as? HomePageTableViewHeader else { return UIView()}
        headerView.configImage(urlString: homePageViewModel.homeImageUrlString.value)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 250
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.prepareForEpisodePage(episodeIndex: indexPath.row)
    }
    
}

