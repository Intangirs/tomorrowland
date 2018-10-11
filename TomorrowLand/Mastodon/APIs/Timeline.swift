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
    class Timeline {
        enum TimelineType {
            case home, `public`, hashtag
        }

        var type: TimelineType
        var hashTag: String
        var listId: String

        init(type: TimelineType, hashtag: String = "", listId: String = "") {
            self.type = type
            self.hashTag = hashtag
            self.listId = listId
        }
        
        private var endpoint: String {
            var endpoint = "https://\(Mastodon.shared.hostname)"
            switch type {
            case .home:
                endpoint += "\(Mastodon.Constants.timelinesHomePath)"
            case .public:
                endpoint += "\(Mastodon.Constants.timelinesPublicPath)"
            case .hashtag:
                endpoint += "\(Mastodon.Constants.timelinesHashtagPath)"
                endpoint = endpoint.replacingOccurrences(of: ":hashtag", with: self.hashTag.urlEncoded())
            }

            return endpoint
        }

        func fetch(options: [String: String] = [:], completion: @escaping (Headers?
, [Status]) -> Void) {
            var header = [String: String]()
            if type == .home {
                header = [
                    "Authorization": "Bearer \(Mastodon.shared.token)"
                ]
            }
            
            Alamofire.request(self.endpoint,
                method: .get,
                parameters: options,
                encoding: URLEncoding.queryString,
                headers: header).validate()
                .responseData { (response) in
                    switch response.result {
                    case .success(let value):
                        do {
                            let decoder = JSONDecoder()
                            let statuses: [Status] = try decoder.decode([Status].self, from: value)

                            var responseHeader: Headers? = nil
                            if let header = response.response?.allHeaderFields {
                                responseHeader = Headers(with: header)
                            }

                            completion(responseHeader, statuses)
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
