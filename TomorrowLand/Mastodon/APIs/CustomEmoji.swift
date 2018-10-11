//
//  CustomEmoji.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/10/12.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import Alamofire

extension Mastodon {
    class CustomEmoji {
        var hostname = Mastodon.shared.hostname
        
        init(hostname: String) {
            self.hostname = hostname
        }

        func fetch(completion: @escaping ([Emoji]?, Error?) -> Void) {
            let endpoint = "https://\(hostname)\(Mastodon.Constants.customEmojiPath)"
            Alamofire.request(URL(string: endpoint)!).validate()
                .responseData(completionHandler: { (response) in
                    switch response.result {
                    case .success(let value):
                        do {
                            let decoder = JSONDecoder()
                            let emojis: [Emoji] = try decoder.decode([Emoji].self, from: value)
                            completion(emojis, nil)
                        } catch {
                            completion(nil, error)
                        }
                    case .failure(let error):
                        completion(nil, error)
                    }
                })
        }
    }
}
