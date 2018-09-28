//
//  PublicViewController.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/09/26.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import UIKit

class PublicViewController: UIViewController {
    var timelineWorker: TimeLineWorker?

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Public".localized()
        self.timelineWorker = TimeLineWorker(with: self.tableView)
        commonSetup(worker: self.timelineWorker!)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Mastodon.Timeline(type: .public).fetch { (statuses) in
            DispatchQueue.main.async {
                self.timelineWorker?.reload(with: statuses)
            }
        }
    }

}
