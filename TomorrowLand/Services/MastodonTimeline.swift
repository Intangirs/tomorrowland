//
//  MastodonTimeline.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/09/30.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import UIKit
import SafariServices

extension UIViewController {
    func commonSetup(worker: TimeLineWorker) {
        worker.configure(process: { (worker) in
            worker.handleURLTap = { url in
                let safari = SFSafariViewController(url: url)
                self.present(safari, animated: true, completion: nil)
            }
            
            worker.didCellSelected = { tableView, indexPath, status in
                Mastodon.Statuses(type: .status, id: status.id).fetch(completion: { (status) in
                    print(status)
                })
            }
            
            worker.handleHashtagTap = { hashtag in
                let hashtagTimeline = HomeViewController()
                hashtagTimeline.timelineType = .hashtag
                hashtagTimeline.hashtag = hashtag
                self.present(hashtagTimeline, animated: true, completion: nil)
            }
        })
    }
    
    func viewTitle(by timelineType: Mastodon.Timeline.TimelineType) -> String {
        var viewTitle = ""
        switch timelineType {
        case .home:
            viewTitle = "Home".localized()
        case .hashtag:
            viewTitle = "Hashtag".localized()
        default:
            viewTitle = "Public".localized()
        }
        
        return viewTitle
    }
}

class TimeLineWorker: NSObject, UITableViewDelegate, UITableViewDataSource {
    var statuses: [Status]
    var tableView: UITableView

    var handleURLTap: ((URL) -> Void)?
    var didCellSelected: ((UITableView, IndexPath, Status) -> Void)?
    var handleHashtagTap: ((String) -> Void)?

    init(with tableView: UITableView) {
        self.statuses = []
        self.tableView = tableView
        super.init()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.register(UINib(nibName: StatusTableViewCell.kIdentifier, bundle: nil), forCellReuseIdentifier: StatusTableViewCell.kIdentifier)
    }
    
    func configure(process: (TimeLineWorker) -> Void) {
        process(self)
    }

    func reload(with statuses: [Status]) {
        self.statuses = statuses
        self.tableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.statuses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell: StatusTableViewCell = tableView.dequeueReusableCell(withIdentifier: StatusTableViewCell.kIdentifier, for: indexPath) as? StatusTableViewCell {
            cell.configure(status: self.statuses[indexPath.row])
            cell.handleURLTapped = handleURLTap
            cell.handleHashtagTapped = handleHashtagTap
            return cell
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        didCellSelected?(tableView, indexPath, statuses[indexPath.row])
    }
}
