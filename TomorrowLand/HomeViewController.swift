//
//  HomeViewController.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/09/25.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import UIKit

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
        if self.timelineWorker?.statuses.count == 0 || self.timelineType == .public {
            reloadTimeline(initially: true)
        }
    }
}

extension HomeViewController {
    func reloadTimeline(initially: Bool) {
        signIntoFederation(shouldAuthenticate: self.timelineType == .home) { result in
            guard result else { return }
            self.timelineWorker?.fetch(initially: initially, timelineType: self.timelineType, hashTag: "", listId: "")
        }
    }    
}
