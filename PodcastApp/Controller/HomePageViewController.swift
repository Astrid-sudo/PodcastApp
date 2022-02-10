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
        table.dataSource = homePageViewModel
        table.delegate = homePageViewModel
        table.allowsSelection = true
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.register(HomePageTableViewCell.self, forCellReuseIdentifier: HomePageTableViewCell.reuseIdentifier)
        table.register(HomePageTableViewHeader.self, forHeaderFooterViewReuseIdentifier: HomePageTableViewHeader.reuseIdentifier)
        return table
    }()
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.color = .darkGray
        view.hidesWhenStopped = true
        return view
    }()
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setTableView()
        setIndicatorView()
        binding()
        indicatorView.startAnimating()
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
    
    private func setIndicatorView() {
        tableView.addSubview(indicatorView)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicatorView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
        ])
    }
    
    // MARK: - method
    
    func binding() {
        homePageViewModel.rssFeedItems.bind { [weak self] _ in
            guard let self = self else { return }
            self.tableView.reloadData()
            self.indicatorView.stopAnimating()
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
    
}

