//
//  Timeline.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/09/25.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import Foundation
import Alamofire

extension Mastodon {
    struct Timeline {
        static func home() {
            Alamofire.request(URL(string: "https://\(Mastodon.shared.hostname)\(Mastodon.Constants.homePath)")!)
        }
        
        static func `public`() {
            
        }
    }
}
