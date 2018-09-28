//
//  Mastodon.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/09/25.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import UIKit

class Mastodon {
    static let shared = Mastodon()

    var hostname: String = ""
    var token: String = ""

    static func load(hostname: String, token: String = "") {
        self.shared.hostname = hostname
        if token.count > 0 {
            self.shared.token = token
        }
    }

    /**
     * Authentication through WebView
     */
    static func addAccount(on viewController: UIViewController, completion: @escaping (Bool, String?, String?) -> Void) {
        let auth = AuthenticationViewController()
        auth.completeBlock = completion
        viewController.present(auth, animated: true, completion: nil)
    }

}
