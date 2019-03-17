//
//  ChartSwitchCellModel.swift
//  TelegramContest
//
//  Created by g.tokmakov on 18/03/2019.
//  Copyright © 2019 g.tokmakov. All rights reserved.
//

import UIKit

protocol ChartSwitchCellModelDelegate: AnyObject {
    func updateUI(sender: ChartSwitchCellModel)
}

class ChartSwitchCellModel {
    private let action: (_ selected: Bool) -> ()
    private let checkIcon = UIImage.ts_image(imageName: "checkmark", renderingMode: .alwaysTemplate)
    private var selected = true
    
    let title: String
    let color: String
    var icon: UIImage? {
        return selected ? checkIcon : nil
    }
    let shouldShowSeparator: Bool
    
    weak var delegate: ChartSwitchCellModelDelegate?
    
    init(title: String, color: String, shouldShowSeparator: Bool, action: @escaping (_ selected:  Bool) -> ()) {
        self.title = title
        self.color = color
        self.shouldShowSeparator = shouldShowSeparator
        self.action = action
    }
    
    func didSelect() {
        selected = !selected
        action(selected)
        delegate?.updateUI(sender: self)
    }
}
