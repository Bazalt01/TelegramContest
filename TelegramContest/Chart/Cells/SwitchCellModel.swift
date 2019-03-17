//
//  SwitchCellModel.swift
//  TelegramContest
//
//  Created by g.tokmakov on 24/03/2019.
//  Copyright © 2019 g.tokmakov. All rights reserved.
//

import Foundation

class SwitchCellModel {
    var colorScheme: ColorScheme
    private let action: os_block_t
    var title: String {
        switch colorScheme {
        case .base:
            return "Switch to Night Mode"
        case .night:
            return "Switch to Day Mode"
        }
    }
    
    init(colorScheme: ColorScheme, action: @escaping os_block_t) {
        self.colorScheme = colorScheme
        self.action = action
    }
    
    func didPress() {
        action()
    }
}
