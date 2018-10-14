//
//  TLUtils.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/10/12.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import UIKit
import KeychainSwift

class TLUtils {

    static var currentHost: String {
        var mastodon_host = "mastodon.social"
        if let hosts = KeychainSwift(keyPrefix: "TL").get("hosts") {
            mastodon_host = String(hosts.split(separator: ",")[0]).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        return mastodon_host
    }
    
    static var currentToken: String {
        return KeychainSwift(keyPrefix: "TL").get(currentHost) ?? ""
    }
    
    @discardableResult
    static func switchHost(for host: String) -> Bool {
        if let hosts = KeychainSwift(keyPrefix: "TL").get("hosts"),
            hosts.contains(host),
            let _ = KeychainSwift(keyPrefix: "TL").get(host) {
            var tmpHosts = hosts.split(separator: ",")
            tmpHosts.removeAll { (substr) -> Bool in
                return substr == host
            }
            tmpHosts.insert(Substring(host), at: 0)
            KeychainSwift(keyPrefix: "TL").set(tmpHosts.joined(separator: ","), forKey: "hosts")
            Mastodon.shared.hostname = host
            Mastodon.shared.token = currentToken
            return true
        }
        
        return false
    }
    
    @discardableResult
    static func addAccount(host: String, token: String) -> Bool {
        if let hosts = KeychainSwift(keyPrefix: "TL").get("hosts"), !hosts.contains(host) {
            KeychainSwift(keyPrefix: "TL").set(hosts + "," + host, forKey: "hosts")
        } else {
            KeychainSwift(keyPrefix: "TL").set(host, forKey: "hosts")
        }
        KeychainSwift(keyPrefix: "TL").set(token, forKey: host)
        return switchHost(for: host)
    }
    
    static func configureTabBarController() -> UITabBarController {
        let tabBarViewController = UITabBarController()
        
        let homeViewController = TLTimelineViewController()
        homeViewController.timelineType = .home
        
        let publicViewController = TLTimelineViewController()
        
        let homeNav = UINavigationController(rootViewController: homeViewController)
        homeNav.tabBarItem = UITabBarItem(title: "Home".localized(), image: nil, tag: 0)
        let publicNav = UINavigationController(rootViewController: publicViewController)
        publicNav.tabBarItem = UITabBarItem(title: "Public".localized(), image: nil, tag: 1)
        
        tabBarViewController.viewControllers = [homeNav, publicNav]
        return tabBarViewController
    }
}
