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
        enum TimelineType {
            case home, `public`
        }
        
        var type: TimelineType

        fileprivate var maxId: String = ""
        fileprivate var sinceId: String = ""
        fileprivate var endpoint: String
        
        init(type: TimelineType, maxId: String = "", sinceId: String = "") {
            self.type = type
            endpoint = "https://\(Mastodon.shared.hostname)"
            switch type {
            case .home:
                endpoint += "\(Mastodon.Constants.timelinesHomePath)"
            case .public:
                endpoint += "\(Mastodon.Constants.timelinesPublicPath)"
            }
        }
        
        func fetch() {
            var header = [String: String]()
            if type == .home {
                header = [
                    "Authorization": "Bearer \(Mastodon.shared.token)"
                ]
            }
            
            Alamofire.request(endpoint,
                method: .get,
                parameters: nil,
                encoding: URLEncoding.queryString,
                headers: header).validate()
                .responseJSON { (response) in
                    debugPrint(response.response?.allHeaderFields)
                    debugPrint(response.value)
            }
        }
        
    }
}
