//
//  TLProfileViewController.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/10/14.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import UIKit

class TLProfileViewController: UIViewController {

    var accountId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let api = AccountAPI(accountId: accountId)
        Session<AccountAPI>(request: api).send { (account, error) in
            if let account = account {
                debugPrint(account)
            } else {
                debugPrint(error)
            }
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
