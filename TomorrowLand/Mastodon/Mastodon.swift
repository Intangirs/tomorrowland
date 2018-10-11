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
    var clientId: String = ""
    var secretId: String = ""
    var scope: String = ""
    var redirectUri: String = ""

    static func load(hostname: String,
                     token: String = "",
                     clientId: String = "",
                     secretId: String = "",
                     scope: String = "",
                     redirectUri: String = "") {
        self.shared.hostname = hostname
        self.shared.clientId = clientId
        self.shared.secretId = secretId
        self.shared.scope = scope
        self.shared.redirectUri = redirectUri

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
