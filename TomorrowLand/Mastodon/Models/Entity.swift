//
//  Entity.swift
//  TomorrowLand
//
//  Created by Ohashi, Yusuke a | Mike | ECMD on 2018/09/27.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import Foundation

class Entity {
    var name: String = ""
    var body: String = ""
    var attrs: [String: String] = [:]
    var entities: [Entity] = [Entity]()
    var open: Bool = true
}