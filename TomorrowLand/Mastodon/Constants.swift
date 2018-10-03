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
        static let timelinesHomePath = "/api/v1/timelines/home"
        static let timelinesPublicPath = "/api/v1/timelines/public"
        static let timelinesHashtagPath = "/api/v1/timelines/tag/:hashtag"
        static let statusesPath = "/api/v1/statuses/:id"
        static let statusesContextPath = "/api/v1/statuses/:id/context"
        static let statusesCardPath = "/api/v1/statuses/:id/card"
    }
}
