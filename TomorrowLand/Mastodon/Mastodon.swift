//
//  Mastodon.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/09/25.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import UIKit

class Mastodon {
    static let shared = Mastodon()
    
    var hostname: String = ""
    var selectedToken: String = ""
    var tokens: [String] = []
    
    static func load(hostname: String, tokens: [String]) {
        self.shared.hostname = hostname
        self.shared.tokens = tokens
        if tokens.count > 0 {
            self.shared.selectedToken = tokens[0]
        }
    }
    
    static func addAccount(on viewController: UIViewController, completion: @escaping (Bool, String?, String?) -> Void) {
        let auth = AuthenticationViewController()
        auth.completeBlock = completion
        viewController.present(auth, animated: true, completion: nil)
    }
}
