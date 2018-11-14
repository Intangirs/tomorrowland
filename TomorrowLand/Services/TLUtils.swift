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
    enum ViewType {
        case home
        case hashtag
        case local
        case federation
        case toot
    }

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
        let tootViewController = TLTootViewController()

        let homeNav = UINavigationController(rootViewController: homeViewController)
        homeNav.tabBarItem = UITabBarItem(title: TLUtils.viewTitle(by: .home), image: nil, tag: MastodonAPI.TimelineType.home.hashValue)
        let tootNav = UINavigationController(rootViewController: tootViewController)
        tootNav.tabBarItem = UITabBarItem(title: TLUtils.viewTitle(by: .toot), image: nil, tag: 599)

        tabBarViewController.viewControllers = [homeNav, tootNav]
        return tabBarViewController
    }

    static func viewTitle(by timelineType: ViewType) -> String {
        var viewTitle = ""
        switch timelineType {
        case .home:
            viewTitle = "Home".localized()
        case .hashtag:
            viewTitle = "Hashtag".localized()
        case .federation:
            viewTitle = "Federation".localized()
        case .toot:
            viewTitle = "Toot".localized()
        default:
            viewTitle = "Local".localized()
        }

        return viewTitle
    }

}
