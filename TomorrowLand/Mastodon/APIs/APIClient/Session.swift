//
//  Session.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/10/14.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import Alamofire

class Session<T: Request> {
    let request: T
    
    init(request: T) {
        self.request = request
    }
    
    func send(completion: @escaping (T.responseType?, Error?) -> Void) {
        guard let url = URL(string: request.endpoint) else {
            return
        }
        
        Alamofire.request(url,
                          method: request.httpMethod,
                          parameters: nil,
                          encoding: URLEncoding.queryString,
                          headers: nil)
            .validate()
            .responseData { (response) in
                switch response.result {
                case .success(let data):
                    do {
                        let response = try self.request.response(data: data)
                        completion(response, nil)
                    } catch {
                        completion(nil, error)
                    }
                case .failure(let error):
                    completion(nil, error)
                }
        }
    }
}
