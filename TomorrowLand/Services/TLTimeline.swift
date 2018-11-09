//
//  MastodonTimeline.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/09/30.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import UIKit

class TLTimeLine: NSObject {
    var statuses: [Status]
    var maxId: String
    var timelineType: MastodonAPI.TimelineType = .home
    var hashTag: String = ""
    var listId: String = ""
    var tableView: UITableView
    var isLoadingMore: Bool = false
    var shouldLoadMore: Bool = true

    var handleURLTap: ((URL) -> Void)?
    var didCellSelected: ((UITableView, IndexPath, Status) -> Void)?
    var handleHashtagTap: ((String) -> Void)?
    var handleUserNameTap: ((Mention) -> Void)?
    private let refreshControl = UIRefreshControl()

    public init(with tableView: UITableView) {
        self.statuses = []
        self.maxId = ""

        self.tableView = tableView
        super.init()

        refreshControl.addTarget(self, action: #selector(refreshTimeline), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.register(UINib(nibName: StatusTableViewCell.kIdentifier, bundle: nil), forCellReuseIdentifier: StatusTableViewCell.kIdentifier)
    }

    public func start(type: MastodonAPI.TimelineType, hashtag: String, listId: String) {
        self.timelineType = type
        self.hashTag = hashtag
        self.listId = listId
        self.statuses = []
        fetch()
    }

}

extension TLTimeLine: UITableViewDelegate, UITableViewDataSource {
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
            cell.handleUserNameTapped = handleUserNameTap
            return cell
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        didCellSelected?(tableView, indexPath, statuses[indexPath.row])
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let contentSize = scrollView.contentSize.height
        let tableSize = scrollView.frame.size.height - scrollView.contentInset.top - scrollView.contentInset.bottom
        let canLoadFromBottom = contentSize > tableSize

        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let difference = maximumOffset - currentOffset

        shouldLoadMore = canLoadFromBottom && difference <= -60.0
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (self.maxId == "" || shouldLoadMore), self.isLoadingMore == false {
            self.fetch()
            shouldLoadMore = false
        }
    }
}

extension TLTimeLine {
    private func fetch() {
        self.isLoadingMore = true

        Mastodon.fetchTimeline(type: self.timelineType, hashTag: self.hashTag, listId: self.listId, maxId: self.maxId) { (result, headers, error) in
            self.isLoadingMore = false
            if let headers = headers {
                self.maxId = headers.maxId
            }
            
            let nonOptionalResult = result ?? []
            if self.statuses.count == 0 {
                self.statuses = nonOptionalResult
            } else {
                self.statuses.append(contentsOf: nonOptionalResult)
            }
            
            DispatchQueue.main.async {
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }

                var startIndex = self.statuses.count - nonOptionalResult.count
                var indexes = [IndexPath]()
                nonOptionalResult.forEach({ (_) in
                    indexes.append(IndexPath(row: startIndex, section: 0))
                    startIndex += 1
                })
                
                self.tableView.reloadData()
            }
        }
    }

    @objc func refreshTimeline() {
        self.maxId = ""
        shouldLoadMore = true
    }
}
