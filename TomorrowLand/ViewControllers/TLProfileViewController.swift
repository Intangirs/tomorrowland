//
//  TLProfileViewController.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/10/14.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import UIKit
import Kiri
import Mastodon

class TLProfileViewController: UIViewController {

    var accountId: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        Kiri<API>(request: .account(accountId)).send { (response, error) in
            if let response = response {
                do {
                    let account: Account = try response.decodeJSON()
                    print(account)
                } catch {
                    print(error)
                }
            } else {
                debugPrint(error ?? "No Error")
            }
        }
    }

}
