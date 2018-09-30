//
//  PublicViewController.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/09/26.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import UIKit

class PublicViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Public".localized()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Mastodon.Timeline(type: .public).fetch()
    }
}
