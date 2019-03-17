//
//  UIView+Additional.swift
//  TelegramContest
//
//  Created by g.tokmakov on 18/03/2019.
//  Copyright © 2019 g.tokmakov. All rights reserved.
//

import UIKit

extension UIView {
    class func tc_reuseIdentifier() -> String {
        return String(describing: self)
    }
}
