//
//  ChartView.swift
//  TelegramContest
//
//  Created by g.tokmakov on 13/03/2019.
//  Copyright © 2019 g.tokmakov. All rights reserved.
//

import UIKit

class ChartCell: UITableViewCell {
    var appearance: ChartCellAppearance? {
        didSet {
            chartGraphicView.appearance = appearance?.chart
            chartHistoryPanel.appearance = appearance?.chartNavigation
            updateAppearance()
        }
    }
    var viewModel: ChartCellModel? {
        didSet {
            updateUI()
        }
    }
    private let chartGraphicView = ChartGraphicView()
    private let chartHistoryPanel = ChartHistoryPanel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        selectionStyle = .none
        
        contentView.addSubview(chartGraphicView)
        chartGraphicView.backgroundColor = UIColor.white
        chartGraphicView.lineWidth = 2
        
        contentView.addSubview(chartHistoryPanel)
        chartHistoryPanel.backgroundColor = UIColor.white
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        chartGraphicView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap(sender: UITapGestureRecognizer) {
        guard let viewModel = viewModel else {
            return
        }
        let value = sender.location(in: self).x / bounds.width
        viewModel.didSelectGraphicPoint(value: value)
    }
    
    private func updateUI() {
        guard let viewModel = viewModel else {
            return
        }
        chartGraphicView.viewModel = viewModel.graphicViewModel
        chartHistoryPanel.viewModel = viewModel.historyViewModel                
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutMargins = contentView.layoutMargins
        let horizontalMargins = layoutMargins.left + layoutMargins.right
        let historyPanelSize = CGSize(width: bounds.width - horizontalMargins, height: 50)
        chartHistoryPanel.frame = CGRect(origin: CGPoint(x: layoutMargins.left, y: bounds.height - historyPanelSize.height - layoutMargins.bottom),
                                         size: historyPanelSize)
        chartHistoryPanel.setNeedsLayout()
        chartGraphicView.frame = CGRect(origin: .init(x: layoutMargins.left, y: 0),
                                        size: CGSize(width: bounds.width - horizontalMargins, height: chartHistoryPanel.frame.minY - layoutMargins.bottom))
        chartGraphicView.setNeedsLayout()
        separatorInset = UIEdgeInsets(top: 0, left: bounds.width, bottom: 0, right: 0)
    }
    
    private func updateAppearance() {
        guard let appearance = appearance else {
            return
        }
        backgroundColor = appearance.backgroundColor
    }
}
