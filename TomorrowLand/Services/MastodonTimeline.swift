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
    var maxId: String
    var tableView: UITableView
    var isLoadingMore: Bool = false
    var timeline: Mastodon.Timeline

    var handleURLTap: ((URL) -> Void)?
    var didCellSelected: ((UITableView, IndexPath, Status) -> Void)?
    var handleHashtagTap: ((String) -> Void)?

    init(with tableView: UITableView) {
        self.statuses = []
        self.maxId = ""
        self.timeline = Mastodon.Timeline(type: .public)
        
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

    func fetch(initially: Bool,
               timelineType: Mastodon.Timeline.TimelineType,
               hashTag: String,
               listId: String) {
        var options: [String: String] = [:]

        if !initially, self.maxId.count > 0 {
            options["max_id"] = self.maxId
        }
        
        self.timeline = Mastodon.Timeline(type: timelineType,
                          hashtag: hashTag,
                          listId: listId)
        
        self.isLoadingMore = true
        self.timeline.fetch(options: options,
                            completion: { (headers, statuses) in
                            if let headers = headers, let link = headers["Link"] as? String {
                                let result = self.extractMaxMinId(link: link)
                                self.maxId = result.0
                                debugPrint(self.maxId)
                            }
                            
                            if initially {
                                self.statuses = statuses
                            } else {
                                self.statuses.append(contentsOf: statuses)
                            }
                            
                            self.isLoadingMore = false
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                          })
    }
    
    fileprivate func extractMaxMinId(link: String) -> (String, String) {
        let elements = link.replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "").split(separator: ",")
        var maxId = ""
        var sinceId = ""
        
        elements.forEach { (element) in
            let link = element.split(separator: ";")[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let rel = element.split(separator: ";")[1].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if rel.contains("next"), let url = URL(string: link) {
                if let query = url.query {
                    query.split(separator: "&").forEach({ (param) in
                        let keyValue = param.split(separator: "=")
                        if keyValue[0] == "max_id" {
                            maxId = String(keyValue[1])
                        }
                    })
                }
            }
            
            if rel.contains("prev"), let url = URL(string: link) {
                if let query = url.query {
                    query.split(separator: "&").forEach({ (param) in
                        let keyValue = param.split(separator: "=")
                        if keyValue[0] == "min_id" {
                            sinceId = String(keyValue[1])
                        }
                    })
                }
            }
        }
        
        return (maxId, sinceId)
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let contentSize = scrollView.contentSize.height
        let tableSize = scrollView.frame.size.height - scrollView.contentInset.top - scrollView.contentInset.bottom
        let canLoadFromBottom = contentSize > tableSize
        
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let difference = maximumOffset - currentOffset
        
        if canLoadFromBottom, difference <= -60.0 {
            
            if (self.isLoadingMore == false) {                
                self.fetch(initially: false, timelineType: self.timeline.type, hashTag: self.timeline.hashTag, listId: self.timeline.listId)
            }
        }
    }
}
