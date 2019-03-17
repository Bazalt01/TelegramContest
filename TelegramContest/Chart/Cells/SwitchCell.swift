//
//  SwitchCell.swift
//  TelegramContest
//
//  Created by g.tokmakov on 24/03/2019.
//  Copyright © 2019 g.tokmakov. All rights reserved.
//

import UIKit

class SwitchCell: UITableViewCell {
    var appearance: SwitchCellAppearance? {
        didSet {
            updateAppearance()
        }
    }
    var viewModel: SwitchCellModel? {
        didSet {
            updateUI()
        }
    }
    private let button = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        selectionStyle = .none
        
        contentView.addSubview(button)
        button.addTarget(self, action: #selector(handlePress(sender:)), for: .touchUpInside)
        button.frame = bounds
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    @objc private func handlePress(sender: UIButton) {
        guard let viewModel = viewModel else {
            return
        }
        viewModel.didPress()
    }
    
    private func updateUI() {
        button.setTitle(viewModel?.title, for: .normal)
        updateAppearance()
    }
    
    private func updateAppearance() {
        guard let appearance = appearance else {
            return
        }
        backgroundColor = appearance.backgroundColor
        button.setTitleColor(appearance.titleColor, for: .normal)
    }
}
