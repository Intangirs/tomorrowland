//
//  AccountAPI.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/10/14.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import Alamofire

class AccountAPI: Request {
    func response(data: Data) throws -> Account {
        let decoder = JSONDecoder()
        return try decoder.decode(responseType.self, from: data)
    }
    
    typealias responseType = Account
    
    var accountId: String
    
    var endpoint: String {
        get {
            let endpoint = "https://" + Mastodon.shared.hostname + Mastodon.Constants.accountsPath
            return endpoint.replacingOccurrences(of: ":id", with: self.accountId.urlEncoded())
        }
        
        set {}
    }
    var httpMethod: HTTPMethod = .get
    
    init(accountId: String) {
        self.accountId = accountId
    }
}
