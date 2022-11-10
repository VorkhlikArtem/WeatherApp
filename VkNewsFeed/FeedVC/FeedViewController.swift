//
//  FeedViewController.swift
//  VkNewsFeed
//
//  Created by Артём on 06.11.2022.
//

import UIKit

protocol NewsfeedDisplayLogic: AnyObject {
  func displayData(viewModel: Newsfeed.Model.ViewModel.ViewModelData)
}

class FeedViewController: UIViewController, NewsfeedDisplayLogic {
  
    @IBOutlet weak var tableView: UITableView!
    let titleView = TitleView()
    private lazy var footerView = FooterView()
    let refreshControl = UIRefreshControl()
    
    var interactor: NewsfeedBusinessLogic?
    private let networkFetcher = NetworkingDataFetcher(networking: NetworkService())
    private var feedViewModel = FeedViewModel(cells: [], footerTitle: nil)
    
    private func setup() {
      let viewController        = self
      let interactor            = FeedInteractor()
      let presenter             = FeedPresenter()
      viewController.interactor = interactor
      interactor.presenter      = presenter
      presenter.viewController  = viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setUpTopBar()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "FeedTableViewCell", bundle: nil), forCellReuseIdentifier: FeedTableViewCell.reuseId)
        tableView.register(FeedCodeTableViewCell.self, forCellReuseIdentifier: FeedCodeTableViewCell.reuseId)
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.refreshControl = refreshControl
        tableView.tableFooterView = footerView
        tableView.contentInset.top = 8
        
        refreshControl.addTarget(self, action: #selector(updateFeed), for: .valueChanged)
        view.backgroundColor = .cyan
        
        interactor?.makeRequest(request: Newsfeed.Model.Request.RequestType.getNewsfeed)
        interactor?.makeRequest(request: .getUser)
    }
    
    private func setUpTopBar() {
        let topBar = UIView(frame: SceneDelegate.shared().window?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero)
        topBar.backgroundColor = .white
        topBar.layer.shadowColor = UIColor.black.cgColor
        topBar.layer.shadowOpacity = 0.3
        topBar.layer.shadowOffset = .zero
        topBar.layer.shadowRadius = 8
        view.addSubview(topBar)
        
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.titleView = titleView
    }
    
    func displayData(viewModel: Newsfeed.Model.ViewModel.ViewModelData) {
        switch viewModel {
        case .displayNewsfeed(let feedViewModel):
            self.feedViewModel = feedViewModel
            footerView.setTitle(feedViewModel.footerTitle)
            tableView.reloadData()
            refreshControl.endRefreshing()
            
        case .displayUserAvatar(userViewModel: let userViewModel):
            titleView.set(imageURL: userViewModel.photoUrlString)
            
        case .displayFooterLoader:
            footerView.showLoader()
        }
    }
    
    @objc func updateFeed() {
        interactor?.makeRequest(request: Newsfeed.Model.Request.RequestType.getNewsfeed)
    }
    
}
extension FeedViewController: UITableViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y > scrollView.contentSize.height / 1.1 {
            interactor?.makeRequest(request: .getNextBatch)
        }
    }
}

extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedViewModel.cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedCodeTableViewCell.reuseId, for: indexPath) as! FeedCodeTableViewCell
        let cellViewModel = feedViewModel.cells[indexPath.row]
        cell.set(viewModel: cellViewModel)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellViewModel = feedViewModel.cells[indexPath.row]
        return cellViewModel.sizes.totalHeight
    }
}

extension FeedViewController: FeedCodeTableViewCellDelegate {
    func revealPostText(for cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        let cellViewModel = feedViewModel.cells[indexPath.row]
        
        interactor?.makeRequest(request: .revealPost(postId: cellViewModel.postId))
    }
    
    
}
