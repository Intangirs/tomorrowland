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

            Mastodon.Timeline(type: self.timelineType,
                              hashtag: self.hashtag,
                              listId: self.listId).fetch(completion: { (statuses) in
                                DispatchQueue.main.async {
                                    self.timelineWorker?.reload(with: statuses)
                                }
                              })
        }
    }
}
