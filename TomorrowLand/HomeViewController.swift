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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Home".localized()
        self.timelineWorker = TimeLineWorker(with: self.tableView)
        commonSetup(worker: self.timelineWorker!)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        signIntoFederation { result in
            guard result else {
                return
            }
            Mastodon.Timeline(type: .home).fetch(completion: { (statuses) in
                DispatchQueue.main.async {
                    self.timelineWorker?.reload(with: statuses)
                }
            })
        }
    }
}
