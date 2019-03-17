//
//  ChartHistoryPanelModel.swift
//  TelegramContest
//
//  Created by g.tokmakov on 15/03/2019.
//  Copyright © 2019 g.tokmakov. All rights reserved.
//

import UIKit

protocol ChartHistoryPanelModelDelegate: AnyObject {
    func didChange(sender: ChartHistoryPanelModel, score: Scope)
}

protocol ChartHistoryPanelModelViewDelegate: AnyObject {
    func updateUI(sender: ChartHistoryPanelModel)
}

private let min: CGFloat = 0.3

class ChartHistoryPanelModel {
    private let charts: [Chart]
    private(set) var graphicViewModel: ChartGraphicViewModel
    var from: CGFloat = 1 - min
    var to: CGFloat = 1
    
    weak var viewDelegate: ChartHistoryPanelModelViewDelegate?
    weak var delegate: ChartHistoryPanelModelDelegate?
    let graphicsColors: [String]
    
    init(charts: [Chart]) {
        self.charts = charts
        self.graphicViewModel = ChartGraphicViewModel(charts: charts, levels: 0)
        self.graphicsColors = charts.map { $0.hexColor }
    }
    
    func change(from: CGFloat) {
        if to - from < min {
           self.from = to - min
        } else {
            self.from = from < 0 ? 0 : from
        }
        viewDelegate?.updateUI(sender: self)
        delegate?.didChange(sender: self, score: Scope(from: self.from, to: self.to))
    }
    
    func change(to: CGFloat) {
        if to - from < min {
            self.to = from + min
        } else {
            self.to = to > 1 ? 1 : to
        }
        viewDelegate?.updateUI(sender: self)
        delegate?.didChange(sender: self, score: Scope(from: self.from, to: self.to))
    }
    
    func change(from: CGFloat, to: CGFloat) {
        let width = self.to - self.from
        if to >= 1 {
            self.to = 1
            self.from = 1 - width
        } else if from < 0 {
            self.from = 0
            self.to = width
        } else {
            self.from = from
            self.to = to
        }
        viewDelegate?.updateUI(sender: self)
        delegate?.didChange(sender: self, score: Scope(from: self.from, to: self.to))
    }
    
    func updateChartVisibility(index: Int, isHidden: Bool) {
        graphicViewModel.updateChartVisibility(index: index, isHidden: isHidden)
    }
}
