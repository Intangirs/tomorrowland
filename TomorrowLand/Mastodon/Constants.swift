//
//  Constants.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/09/23.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import Foundation

extension Mastodon {
    struct Constants {
        static let oauthAuthorizePath = "/oauth/authorize"
        static let oauthTokenPath = "/oauth/token"
        static let oauthRedirectPath = "/oauth/authorize/native"
        static let homePath = "/api/v1/timelines/home"
    }
}
