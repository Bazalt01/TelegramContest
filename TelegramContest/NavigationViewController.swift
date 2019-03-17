//
//  NavigationViewController.swift
//  TelegramContest
//
//  Created by g.tokmakov on 24/03/2019.
//  Copyright © 2019 g.tokmakov. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {
    var statusBarStyle: UIStatusBarStyle = .default
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
}
