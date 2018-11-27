//
//  TLTimelineViewController.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/09/25.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import UIKit
import SafariServices
import Kiri
import Mastodon

class TLTimelineViewController: UIViewController, TLLoginRequired {

    var timelineWorker: TLTimeLine?

    @IBOutlet weak var tableView: UITableView!
    var timelineType: MastodonAPI.TimelineType = .local
    var keyword: String = ""
    var hashtag: String = ""
    var listId: String = ""
    var maxId: String = ""

    var viewTitle: TLUtils.ViewType {
        get {
            switch timelineType {
            case .federation:
                return .federation
            case .home:
                return .home
            case .local:
                return .local
            case .hashtag:
                return .hashtag
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = TLUtils.viewTitle(by: viewTitle)
        self.timelineWorker = TLTimeLine(with: self.tableView)
        commonSetup(worker: self.timelineWorker!)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        signIntoFederation(shouldAuthenticate: self.timelineType == .home) { result in
            guard result else { return }
            self.timelineWorker?.start(type: self.timelineType, hashtag: self.hashtag, listId: self.listId)
        }
    }

}

// MARK: Helpers

extension TLTimelineViewController {
    private func commonSetup(worker: TLTimeLine) {
        worker.handleURLTap = { url in
            let safari = SFSafariViewController(url: url)
            self.present(safari, animated: true, completion: nil)
        }

        worker.didCellSelected = { tableView, indexPath, status in
            Kiri<API>(request: .status(.status, status.id)).send(completion: { (response, error) in
                do {
                    if let response = response, let status: Status = try response.decodeJSON() {
                        print(status)
                    } else {
                        print(error ?? "")
                    }
                } catch {
                    print(error)
                }
            })
        }

        worker.handleHashtagTap = { hashtag in
            let hashtagTimeline = TLTimelineViewController()
            hashtagTimeline.timelineType = .hashtag
            hashtagTimeline.hashtag = hashtag
            let hashNav = UINavigationController(rootViewController: hashtagTimeline)
            self.present(hashNav, animated: true, completion: nil)
        }

        worker.handleUserNameTap = { mention in
            let profile = TLProfileViewController()
            profile.accountId = mention.id
            self.navigationController?.pushViewController(profile, animated: true)
        }

        if timelineType == .hashtag {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close".localized(), style: .plain, target: self, action: #selector(close))
        }
    }

    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
}
