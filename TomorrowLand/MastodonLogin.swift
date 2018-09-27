//
//  MastodonLogin.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/09/26.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

protocol MastodonLoginRequired {
    func signIntoFederation(instance: String, done: @escaping (Bool) -> Void)
}
