//
//  OAuth.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/09/26.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import Foundation
import Alamofire

extension Mastodon {
    class OAuth {
        static func token(code: String, completion: @escaping (Bool, String?) -> Void) {
            let endpoint = "https://\(Mastodon.shared.hostname)\(Mastodon.Constants.oauthTokenPath)"
            Alamofire.request(endpoint,
                method: .post,
                parameters: [
                    "code": code,
                    "client_id": Keys.MASTODON_CLIENT_ID,
                    "client_secret": Keys.MASTODON_CLIENT_SECRET,
                    "redirect_uri": Keys.MASTODON_REDIRECT_URI,
                    "grant_type": "authorization_code"],
                encoding: URLEncoding.httpBody,
                headers: nil)
                .validate()
                .responseData { (response) in
                    switch response.result {
                    case .success(let value):
                        do {
                            //created the json decoder
                            let decoder = JSONDecoder()
                            //using the array to put values
                            let token = try decoder.decode(Token.self, from: value)
                            Mastodon.shared.token = token.access_token
                            completion(true, token.access_token)
                        } catch {
                            completion(false, nil)
                        }
                    case .failure:
                        completion(false, nil)
                    }
            }
        }
    }
}
