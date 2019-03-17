//
//  UIColor+Additional.swift
//  TelegramContest
//
//  Created by g.tokmakov on 15/03/2019.
//  Copyright © 2019 g.tokmakov. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(tc_hex hex: String?) {
        guard let hex = hex else {
            self.init(white: 0.5, alpha: 1)
            return
        }
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        
        if cString.count != 6 {
            self.init(white: 0.5, alpha: 1)
        } else {
            var rgbValue:UInt32 = 0
            Scanner(string: cString).scanHexInt32(&rgbValue)
            self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                      alpha: 1.0)
        }
    }
}
