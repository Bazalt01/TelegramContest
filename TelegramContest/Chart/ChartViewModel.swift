//
//  ChartViewModel.swift
//  TelegramContest
//
//  Created by g.tokmakov on 24/03/2019.
//  Copyright © 2019 g.tokmakov. All rights reserved.
//

import Foundation

protocol ChartViewModelDelegate: AnyObject {
    func updateUI(sender: ChartViewModel)
}

class ChartViewModel {
    private var colorScheme: ColorScheme = .base {
        didSet {
            appearance = AppearanceBuilder.build(scheme: colorScheme)
        }
    }
    
    weak var delegate: ChartViewModelDelegate?
    
    private(set) var switchCellModel: SwitchCellModel!
    private(set) var appearance: Appearance
    
    init() {
        self.appearance = AppearanceBuilder.build(scheme: colorScheme)
        self.switchCellModel = SwitchCellModel(colorScheme: colorScheme, action: { [weak self] in
            self?.switchColorScheme()
        })
    }
    
    private func switchColorScheme() {
        if colorScheme == .base {
            colorScheme = .night
        } else {
            colorScheme = .base
        }
        switchCellModel.colorScheme = colorScheme
        delegate?.updateUI(sender: self)
    }
}
