//
//  StatusTableViewCell.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/09/27.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import UIKit
import ActiveLabel
import Kingfisher

class StatusTableViewCell: UITableViewCell {

    static let kIdentifier = "StatusTableViewCell"

    @IBOutlet weak var boostedLabel: UILabel!
    @IBOutlet weak var attachementBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var attatchmentView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var contentLabel: ActiveLabel!
    @IBOutlet weak var avatarImage: UIImageView!

    @IBOutlet weak var previewImageHeight: NSLayoutConstraint!
    var handleURLTapped: ((URL) -> Void)?
    var handleHashtagTapped: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarImage.layer.cornerRadius = 6.0
        avatarImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        boostedLabel.text = ""
    }

    public func configure(status: Status) {
        attachementBottomSpace.constant = 8
        previewImageHeight.constant = 168
        contentLabel.textColor = UIColor.white
        usernameLabel.textColor = UIColor.white
        boostedLabel.text = ""
        
        contentLabel.enabledTypes = [.mention, .hashtag, .url]
        
        contentLabel.handleURLTap { url in
            self.handleURLTapped?(url)
        }
        
        contentLabel.handleHashtagTap { (hashtag) in
            self.handleHashtagTapped?(hashtag)
        }

        if let reblog_status = status.reblog {
            boostedLabel.text = "\(status.account.display_name) boosted"
            configureContent(reblog_status)
        } else {
            configureContent(status)
        }
    }

    // MARK: Helpers

    fileprivate func configureContent(_ status: Status) {
        contentLabel.text = status.content
        if status.account.display_name.count > 0 {
            usernameLabel.text = status.account.display_name
        } else {
            usernameLabel.text = status.account.username
        }
        
        let url = URL(string: status.account.avatar)!
        avatarImage.kf.setImage(with: url)

        if status.media_attachments.count > 0 {
            let imageUrl = URL(string: status.media_attachments[0].preview_url)!
            let size = attatchmentView.bounds.size

            let processor = CroppingImageProcessor(size: CGSize(width: size.width, height: 168), anchor: CGPoint(x: 0.5, y: 0.5))

            attatchmentView.kf.indicatorType = .activity
            attatchmentView.kf.setImage(with: imageUrl,
                                        options: [.processor(processor)],
                                        completionHandler: {
                                            [weak self] (image, error, cacheType, imageUrl) in
                                            if let strongSelf = self {
                                                strongSelf.setNeedsLayout()
                                            }
                                            
            })
        } else {
            previewImageHeight.constant = 0
        }
    }

    func cropThumbnailImage(image: UIImage, w: CGFloat, h: CGFloat) -> UIImage {
        guard let origRef = image.cgImage else {
            return image
        }
        
        // resize

        let origWidth  = CGFloat(origRef.width)
        let origHeight = CGFloat(origRef.height)
        var resizeWidth: CGFloat = 0.0, resizeHeight: CGFloat = 0.0

        if (origWidth < origHeight) {
            resizeWidth = w
            resizeHeight = origHeight * resizeWidth / origWidth
        } else {
            resizeHeight = h
            resizeWidth = origWidth * resizeHeight / origHeight
        }

        let resizeSize = CGSize.init(width: CGFloat(resizeWidth), height: CGFloat(resizeHeight))

        UIGraphicsBeginImageContext(resizeSize)

        image.draw(in: CGRect.init(x: 0, y: 0, width: CGFloat(resizeWidth), height: CGFloat(resizeHeight)))

        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // crop
        
        guard let resizedImage = resizeImage, let resizedImageRef = resizedImage.cgImage else {
            return image
        }

        let cropRect  = CGRect.init(x: (resizeWidth - w) / 2, y: (resizeHeight - h) / 2, width: w, height: h)
        if let cropRef = resizedImageRef.cropping(to: cropRect) {
            return UIImage(cgImage: cropRef)
        }
        
        return resizedImage
    }

}
