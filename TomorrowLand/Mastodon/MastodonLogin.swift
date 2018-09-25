//
//  MastodonLogin.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/09/26.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import UIKit

protocol MastodonLoginRequired {
    func signIntoFederation() -> Bool
}

extension MastodonLoginRequired where Self: UIViewController {
    func signIntoFederation() -> Bool {
        Mastodon.load(hostname: "mastodon.social", tokens: [])
        if Mastodon.shared.tokens.count == 0 {
            Mastodon.addAccount(on: self) { success, hostname, newToken in
                guard success, let host = hostname, let token = newToken else {
                    return
                }
                
                // persist data
                Mastodon.shared.hostname = host
                Mastodon.shared.tokens = [token]
                Mastodon.shared.selectedToken = token
            }
            return true
        } else {
            return false
        }
    }
}
