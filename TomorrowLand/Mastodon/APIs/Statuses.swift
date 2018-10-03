//
//  Statuses.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/10/03.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import Foundation

import Foundation
import Alamofire

extension Mastodon {
    struct Statuses {
        
        enum StatusesType {
            case status, context, card
        }
        
        var id: String
        var endpoint: String
        var type: StatusesType
        
        init(type: StatusesType, id: String = "") {
            self.id = id
            self.type = type
            
            endpoint = "https://\(Mastodon.shared.hostname)"

            switch type {
            case .status:
                endpoint += Constants.statusesPath
            case .context:
                endpoint += Constants.statusesContextPath
            case .card:
                endpoint += Constants.statusesCardPath
            }
            endpoint = endpoint.replacingOccurrences(of: ":id", with: id)
        }
        
        func fetch(completion: @escaping (Status) -> Void) {

            Alamofire.request(endpoint,
                              method: .get,
                              parameters: nil,
                              encoding: URLEncoding.queryString,
                              headers: nil).validate()
                .responseData { (response) in
                    switch response.result {
                    case .success(let value):
                        do {
                            let decoder = JSONDecoder()
                            let status: Status = try decoder.decode(Status.self, from: value)
                            completion(status)
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
