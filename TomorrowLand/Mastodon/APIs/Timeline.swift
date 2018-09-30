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

        func fetch(completion: @escaping ([Status]) -> Void) {
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
                .responseData { (response) in
                    switch response.result {
                    case .success(let value):
                        do {
                            let decoder = JSONDecoder()
                            let statuses: [Status] = try decoder.decode([Status].self, from: value)
                            completion(statuses)
                        } catch {
                            debugPrint(error)
                        }
                    case .failure(let error):
                        debugPrint(error)
                    }
            }
        }

    }
}
