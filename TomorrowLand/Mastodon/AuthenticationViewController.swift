//
//  AuthenticationViewController.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/09/23.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import UIKit

class AuthenticationViewController: UIViewController {

    @IBOutlet weak var instanceHostLabel: UITextField!
    @IBOutlet weak var authorizeButton: UIButton!

    var completeBlock: ((Bool, String?, String?) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        authorizeButton.setTitle("Authorize".localized(), for: .normal)
    }

    @IBAction func startAuthorization(_ sender: Any) {
        let web = OAuth2WebViewController()
        web.hostName = instanceHostLabel.text ?? ""
        web.authCallBack = { result, token in
            DispatchQueue.main.async {
                if result {
                    self.dismiss(animated: true, completion: {
                        self.completeBlock?(result, result ? web.hostName: nil, token)
                    })
                }
            }
        }

        if web.hostName.count > 0 {
            present(web, animated: false, completion: nil)
        }
    }
}
