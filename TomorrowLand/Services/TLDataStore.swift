//
//  TLDataStore.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/10/14.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import UIKit

class TLDataStore {
    private static let shared = TLDataStore()
    private let cache: NSCache<AnyObject, AnyObject>

    init() {
        cache = NSCache<AnyObject, AnyObject>()
    }

    static func store<T>(object: T, forKey: String) {
        shared.cache.setObject(object as AnyObject, forKey: forKey as AnyObject)
    }

    static func load<T>(for key: String) -> T? {
        return shared.cache.object(forKey: key as AnyObject) as? T ?? nil
    }
}
