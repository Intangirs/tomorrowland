//
//  Request.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/10/14.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import Alamofire

protocol Request {
    associatedtype responseType
    var endpoint: String { get set }
    var httpMethod: Alamofire.HTTPMethod { get set }
    func response(data: Data) throws -> responseType
}
