//
//  String+TomorrowLand.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/09/23.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import Foundation

extension String {
    func urlEncoded() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
    
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
