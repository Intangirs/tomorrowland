//
//  TLUtils.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/10/12.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import Foundation
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
        let localViewController = TLTimelineViewController()
        localViewController.timelineType = .local
        let federatedViewController = TLTimelineViewController()
        federatedViewController.timelineType = .federation
        
        let homeNav = UINavigationController(rootViewController: homeViewController)
        homeNav.tabBarItem = UITabBarItem(title: TLUtils.viewTitle(by: .home), image: nil, tag: Mastodon.Timeline.TimelineType.home.hashValue)
        let localNav = UINavigationController(rootViewController: localViewController)
        localNav.tabBarItem = UITabBarItem(title: TLUtils.viewTitle(by: .local), image: nil, tag: Mastodon.Timeline.TimelineType.local.hashValue)
        let federatedNav = UINavigationController(rootViewController: federatedViewController)
        federatedNav.tabBarItem = UITabBarItem(title: TLUtils.viewTitle(by: .federation), image: nil, tag: Mastodon.Timeline.TimelineType.federation.hashValue)

        tabBarViewController.viewControllers = [homeNav, localNav, federatedNav]
        return tabBarViewController
    }
    
    static func viewTitle(by timelineType: Mastodon.Timeline.TimelineType) -> String {
        var viewTitle = ""
        switch timelineType {
        case .home:
            viewTitle = "Home".localized()
        case .hashtag:
            viewTitle = "Hashtag".localized()
        case .federation:
            viewTitle = "Federation".localized()
        default:
            viewTitle = "Local".localized()
        }
        
        return viewTitle
    }

}
