//
//  HomeViewController.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/09/25.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import UIKit
import SafariServices

class HomeViewController: UIViewController, MastodonLoginRequired {
    var timelineWorker: TimeLineWorker?

    @IBOutlet weak var tableView: UITableView!
    var timelineType: Mastodon.Timeline.TimelineType = .public
    var keyword: String = ""
    var hashtag: String = ""
    var listId: String = ""
    var maxId: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = viewTitle(by: timelineType)
        self.timelineWorker = TimeLineWorker(with: self.tableView)
        commonSetup(worker: self.timelineWorker!)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        signIntoFederation(shouldAuthenticate: self.timelineType == .home) { result in
            guard result else { return }
            self.timelineWorker?.start(type: self.timelineType, hashtag: self.hashtag, listId: self.listId)
        }
    }
    
}

// MARK: Helpers

extension HomeViewController {
    private func commonSetup(worker: TimeLineWorker) {
        worker.handleURLTap = { url in
            let safari = SFSafariViewController(url: url)
            self.present(safari, animated: true, completion: nil)
        }
        
        worker.didCellSelected = { tableView, indexPath, status in
            Mastodon.Statuses(type: .status, id: status.id).fetch(completion: { (status) in
                print(status)
            })
        }
        
        worker.handleHashtagTap = { hashtag in
            let hashtagTimeline = HomeViewController()
            hashtagTimeline.timelineType = .hashtag
            hashtagTimeline.hashtag = hashtag
            let hashNav = UINavigationController(rootViewController: hashtagTimeline)
            self.present(hashNav, animated: true, completion: nil)
        }
        
        if timelineType == .hashtag {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close".localized(), style: .plain, target: self, action: #selector(close))
        }
    }
    
    private func viewTitle(by timelineType: Mastodon.Timeline.TimelineType) -> String {
        var viewTitle = ""
        switch timelineType {
        case .home:
            viewTitle = "Home".localized()
        case .hashtag:
            viewTitle = "Hashtag".localized()
        default:
            viewTitle = "Public".localized()
        }
        
        return viewTitle
    }
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
}

