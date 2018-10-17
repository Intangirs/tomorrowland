//
//  MastodonLogin.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/09/26.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import KeychainSwift

protocol TLLoginRequired {
    func signIntoFederation(shouldAuthenticate: Bool, done: @escaping (Bool) -> Void)
}

extension TLLoginRequired where Self: UIViewController {

    func signIntoFederation(shouldAuthenticate: Bool, done: @escaping (Bool) -> Void) {
        guard shouldAuthenticate else {
            done(true)
            return
        }

        if Mastodon.shared.token.count > 0 {
            done(true)
        } else {
            Mastodon.addAccount(on: self) { success, hostname, newToken in
                guard success, let host = hostname, let token = newToken else {
                    done(false)
                    return
                }

                TLUtils.addAccount(host: host, token: token)
                done(true)
            }
        }
    }
}
