//
//  MastodonLogin.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/09/26.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import KeychainSwift

protocol MastodonLoginRequired {
    func signIntoFederation(instance: String, done: @escaping (Bool) -> Void)
}

extension MastodonLoginRequired where Self: UIViewController {

    func signIntoFederation(instance: String = "mastodon.social", done: @escaping (Bool) -> Void) {
        if let token = KeychainSwift(keyPrefix: "TL").get(instance), token.count > 0 {
            Mastodon.load(hostname: instance, token: token)
            done(true)
        } else {
            Mastodon.load(hostname: instance)
            Mastodon.addAccount(on: self) { success, hostname, newToken in
                guard success, let host = hostname, let token = newToken else {
                    done(false)
                    return
                }

                // persist data into secure storage
                Mastodon.shared.hostname = host
                Mastodon.shared.token = token
                KeychainSwift(keyPrefix: "TL").set(token, forKey: host)
                done(true)
            }
        }
    }
}
