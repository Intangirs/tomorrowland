//
//  UIImageView+TL.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/10/14.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher

extension UIImageView {
    fileprivate func displayImage(_ image: UIImage) {
        DispatchQueue.main.async {
            if let gif = image.images {
                self.image = gif.last
                self.animationImages = gif
                self.animationDuration = image.duration
                self.startAnimating()
            } else {
                self.image = image
            }
        }
    }
    
    func tl_setImage(with url: URL, filter: KingfisherOptionsInfo? = nil) {
        DispatchQueue.main.async {
            self.image = nil
        }
        
        if let image: UIImage = TLDataStore.load(for: url.absoluteString) {
            displayImage(image)
            return
        }
        
        self.kf.setImage(with: url, placeholder: nil, options: filter, progressBlock: nil) { (image, error, cachtype, url) in
            if let image = image, let url = url {
                TLDataStore.store(object: image, forKey: url.absoluteString)
                self.displayImage(image)
            }
        }
    }    
}
