//
//  ChartSwitchCell.swift
//  TelegramContest
//
//  Created by g.tokmakov on 18/03/2019.
//  Copyright © 2019 g.tokmakov. All rights reserved.
//

import UIKit

class ChartSwitchCell: UITableViewCell {
    var appearance: ChartSwitchCellAppearance? {
        didSet {
            updateAppearance()
        }
    }
    private let indicatorView = UIView()
    private let titleLabel = UILabel()
    private let checkImageView = UIImageView()
    private let separator = UIView()
    
    var viewModel: ChartSwitchCellModel? {
        didSet {
            viewModel?.delegate = self
            updateUI()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let spacing: CGFloat = 20
        let bounds = contentView.bounds
        let layoutMargins = contentView.layoutMargins
        let indicatorViewSize = CGSize(width: 16, height: 16)
        indicatorView.frame = CGRect(origin: .init(x: layoutMargins.left,
                                                   y: (bounds.height - indicatorViewSize.height) / 2),
                                     size: indicatorViewSize)
        
        checkImageView.sizeToFit()
        checkImageView.frame = CGRect(origin: .init(x: bounds.width - layoutMargins.right - checkImageView.bounds.width,
                                                    y: (bounds.height - checkImageView.bounds.height) / 2),
                                      size: checkImageView.bounds.size)
        
        titleLabel.frame = CGRect(origin: .init(x: indicatorView.frame.maxX + spacing, y: 0),
                                  size: .init(width: checkImageView.frame.minX - indicatorView.frame.maxX - spacing * 2, height: bounds.height))
        separatorInset = UIEdgeInsets(top: 0, left: bounds.width, bottom: 0, right: 0)
        
        let separatorX = titleLabel.frame.minX
        separator.frame = CGRect(origin: .init(x: separatorX, y: bounds.height), size: .init(width: bounds.width - separatorX, height: 0.5))
    }
    
    private func configure() {
        selectionStyle = .none
        
        contentView.addSubview(indicatorView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkImageView)
        contentView.addSubview(separator)
        
        indicatorView.layer.cornerRadius = 4
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        contentView.addGestureRecognizer(tap)
    }
    
    @objc private func handleTap(sender: UITapGestureRecognizer) {
        viewModel?.didSelect()
    }
    
    private func updateUI() {
        indicatorView.backgroundColor = UIColor.init(tc_hex: viewModel?.color)
        titleLabel.text = viewModel?.title
        checkImageView.image = viewModel?.icon
        separator.isHidden = viewModel?.shouldShowSeparator == false
        
        updateAppearance()
    }
    
    private func updateAppearance() {
        guard let appearance = appearance else {
            return
        }        
        titleLabel.textColor = appearance.titleColor
        separator.backgroundColor = appearance.separatorColor
        backgroundColor = appearance.backgroundColor
    }
}

extension ChartSwitchCell: ChartSwitchCellModelDelegate {
    func updateUI(sender: ChartSwitchCellModel) {
        updateUI()
    }
}
