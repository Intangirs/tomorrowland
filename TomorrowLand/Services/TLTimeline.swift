//
//  MastodonTimeline.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/09/30.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import UIKit

class TLTimeline: NSObject {
    var statuses: [Status]
    var maxId: String
    var tableView: UITableView
    var isLoadingMore: Bool = false
    var shouldLoadMore: Bool = false
    var timeline: Mastodon.Timeline
    
    var handleURLTap: ((URL) -> Void)?
    var didCellSelected: ((UITableView, IndexPath, Status) -> Void)?
    var handleHashtagTap: ((String) -> Void)?
    private let refreshControl = UIRefreshControl()
    
    public init(with tableView: UITableView) {
        self.statuses = []
        self.maxId = ""
        self.timeline = Mastodon.Timeline(type: .public)
        
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
    
    public func start(type: Mastodon.Timeline.TimelineType, hashtag: String, listId: String) {
        if self.statuses.count == 0 || type == .public {
            fetch(initially: true, timelineType: type, hashTag: hashtag, listId: listId)
        }
    }
    
}

extension TLTimeline: UITableViewDelegate, UITableViewDataSource {
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
        if shouldLoadMore, self.isLoadingMore == false {
            self.fetch(initially: false,
                       timelineType: self.timeline.type,
                       hashTag: self.timeline.hashTag,
                       listId: self.timeline.listId)
            shouldLoadMore = false
        }
    }
}

extension TLTimeline {
    private func fetch(initially: Bool,
                       timelineType: Mastodon.Timeline.TimelineType,
                       hashTag: String,
                       listId: String) {
        var options: [String: String] = [:]
        
        if !initially, self.maxId.count > 0 {
            options["max_id"] = self.maxId
        }
        
        self.timeline.type = timelineType
        self.timeline.hashTag = hashTag
        self.timeline.listId = listId
        
        self.isLoadingMore = true
        self.timeline.fetch(options: options,
                            completion: { (headers, statuses) in
                                
                                if let headers = headers {
                                    self.maxId = headers.maxId
                                    debugPrint(self.maxId)
                                }
                                
                                if initially {
                                    self.statuses = statuses
                                } else {
                                    self.statuses.append(contentsOf: statuses)
                                }
                                
                                self.isLoadingMore = false
                                
                                DispatchQueue.main.async {
                                    if self.refreshControl.isRefreshing {
                                        self.refreshControl.endRefreshing()
                                    }
                                    
                                    if self.statuses.count > 0, statuses.count > 0 {
                                        self.tableView.reloadData()
                                        self.tableView.scrollToRow(at: IndexPath(row: self.statuses.count - statuses.count, section: 0), at: UITableViewScrollPosition.middle, animated: false)
                                    }
                                }
        })
    }
    
    @objc func refreshTimeline() {
        fetch(initially: true,
              timelineType: self.timeline.type,
              hashTag: self.timeline.hashTag,
              listId: self.timeline.listId)
    }
}
