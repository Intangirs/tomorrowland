//
//  StatusTableViewCell.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/09/27.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import UIKit
import ActiveLabel
import Alamofire
import AlamofireImage

class StatusTableViewCell: UITableViewCell {
    
    static let kIdentifier = "StatusTableViewCell"
    
    @IBOutlet weak var boostedLabel: UILabel!
    @IBOutlet weak var attachementBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var attatchmentView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var contentLabel: ActiveLabel!
    @IBOutlet weak var avatarImage: UIImageView!
    var imageDownloader = ImageDownloader()
    
    @IBOutlet weak var previewImageHeight: NSLayoutConstraint!
    var handleURLTapped: ((URL) -> Void)?
    var handleHashtagTapped: ((String) -> Void)?
    var handleUserNameTapped: ((Mention) -> Void)?
    
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
        contentLabel.text = ""
        contentLabel.attributedText = nil
        attatchmentView.image = nil
        avatarImage.image = nil
    }
    
    public func configure(status: Status) {
        attachementBottomSpace.constant = 8
        previewImageHeight.constant = 168
        contentLabel.textColor = UIColor.white
        usernameLabel.textColor = UIColor.white
        boostedLabel.text = ""
        contentLabel.text = ""
        contentLabel.attributedText = nil
        
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
    
    func matches(for regex: String, in text: String) -> [NSTextCheckingResult] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            return regex.matches(in: text,
                                 range: NSRange(text.startIndex..., in: text))
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        var newImage: UIImage? = image.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: rect)
        UIColor.white.set()
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    fileprivate func configureContent(_ status: Status) {
        
        contentLabel.handleMentionTap { (mention) in
            if let mention = status.mention(by: mention) {
                self.handleUserNameTapped?(mention)
            }
        }

        let contentString = NSMutableAttributedString(string: status.content)
        
        let url = URL(string: status.account.avatar)!
        avatarImage.af_setImage(withURL: url)
        
        var loadCount = 0
        var imageStore: [String: UIImage] = [:]
        if status.emojis.count > 0 {
            status.emojis.forEach { (emoji) in
                imageDownloader.download(URLRequest(url: URL(string: emoji.static_url)!)) { (response) in
                    loadCount += 1
                    
                    if let image = response.result.value {
                        imageStore[emoji.shortcode] = image
                    }
                    
                    if loadCount == status.emojis.count {
                        imageStore.keys.forEach({ (key) in
                            let matchedWords = self.matches(for: "\(key)", in: contentString.string)
                            matchedWords.forEach({ (word) in
                                DispatchQueue.main.async {
                                    if let resizedImage = self.resizeImage(image: imageStore[key]!, targetSize: CGSize(width: 30.0, height: 30.0)) {
                                        let dashAttachment = NSTextAttachment()
                                        dashAttachment.image = imageStore[key]
                                        //contentString.replaceCharacters(in: word.range, with: NSAttributedString(attachment: dashAttachment))
                                        contentString.append(NSAttributedString(attachment: dashAttachment))
                                        self.contentLabel.attributedText = contentString
                                    }
                                }
                            })
                        })
                    }
                }
            }
        } else {
            contentLabel.attributedText = contentString
        }
        
        if status.account.display_name.count > 0 {
            usernameLabel.text = status.account.display_name
        } else {
            usernameLabel.text = status.account.username
        }
        
        if status.media_attachments.count > 0 {
            let imageUrl = URL(string: status.media_attachments[0].url)!
            let size = attatchmentView.bounds.size
            let filter = AspectScaledToFillSizeFilter(size: CGSize(width: size.width, height: 168))
            attatchmentView.af_setImage(withURL: imageUrl, placeholderImage: nil, filter: filter)
        } else {
            previewImageHeight.constant = 0
        }

    }
    
}

class CropImageFilter: ImageFilter, Sizable {
    var size: CGSize
    
    var filter: (Image) -> Image {
        return { image in
            let imageViewScale = max(image.size.width / self.size.width,
                                     image.size.height / self.size.height)
            
            // Scale cropRect to handle images larger than shown-on-screen size
            var posX = image.size.width/2 - self.size.width/2
            if posX < 0 { posX = 0 }
            var posY = image.size.height/2 - self.size.height/2
            if posY < 0 { posY = 0 }
            
            let cropZone = CGRect(x: posX * imageViewScale,
                                  y: posY * imageViewScale,
                                  width: self.size.width * imageViewScale,
                                  height:self.size.height * imageViewScale)
            
            // Perform cropping in Core Graphics
            guard let cutImageRef: CGImage = image.cgImage?.cropping(to:cropZone)
                else {
                    return image
            }
            
            // Return image to UIImage
            let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
            return croppedImage
        }
    }
    
    init(size: CGSize) {
        self.size = size
    }
    
    private func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage
    {
        let imageViewScale = max(inputImage.size.width / viewWidth,
                                 inputImage.size.height / viewHeight)
        
        // Scale cropRect to handle images larger than shown-on-screen size
        let cropZone = CGRect(x:cropRect.origin.x * imageViewScale,
                              y:cropRect.origin.y * imageViewScale,
                              width:cropRect.size.width * imageViewScale,
                              height:cropRect.size.height * imageViewScale)
        
        // Perform cropping in Core Graphics
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to:cropZone)
            else {
                return inputImage
        }
        
        // Return image to UIImage
        let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
        return croppedImage
    }
}
