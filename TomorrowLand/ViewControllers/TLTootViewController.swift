//
//  TLTootViewController.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/10/16.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import UIKit
import Kiri

class TLTootViewController: UIViewController {

    @IBOutlet weak var tootView: UITextView!
    @IBOutlet weak var tootButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func postToot(_ sender: Any) {
        Kiri<MastodonAPI>(request: .toot(tootView.text, [], false)).send { (response, error) in
            debugPrint(error ?? "no error")
        }
    }
}
