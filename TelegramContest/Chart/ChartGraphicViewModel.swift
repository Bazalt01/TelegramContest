//
//  ChartGraphicViewModel.swift
//  TelegramContest
//
//  Created by g.tokmakov on 13/03/2019.
//  Copyright © 2019 g.tokmakov. All rights reserved.
//

import UIKit

protocol ChartGraphicViewModelDelegate: AnyObject {
    func updateVisibility(sender: ChartGraphicViewModel, from: [CGFloat], to: [CGFloat])
    func updateScope(sender: ChartGraphicViewModel)
    func updateSelectedPoint(sender: ChartGraphicViewModel, value: CGFloat?)
}

class ChartGraphicViewModel {    
    private(set) var scope: Scope = Scope(from: 0, to: 1)

    let charts: [Chart]
    let levels: Int
    let visibleDatesCount = 6
    let shouldShowDates: Bool
    var selectedPoint: CGFloat? {
        didSet {
            self.delegate?.updateSelectedPoint(sender: self, value: selectedPoint)
        }
    }
    
    weak var delegate: ChartGraphicViewModelDelegate?
    
    init(charts: [Chart], levels: Int, shouldShowDates: Bool = false) {
        self.charts = charts
        self.levels = levels
        self.shouldShowDates = shouldShowDates
    }
    
    func update(scope: Scope) {
        self.scope = scope
        delegate?.updateScope(sender: self)
    }
    
    func updateChartVisibility(index: Int, isHidden: Bool) {
        let from = charts.map({ chart -> CGFloat in
            return chart.isHidden ? 0 : 1
        })
        charts[index].isHidden = isHidden
        let to = charts.map({ chart -> CGFloat in
            return chart.isHidden ? 0 : 1
        })
        delegate?.updateVisibility(sender: self, from: from, to: to)
    }
}

extension ChartGraphicViewModel: ChartHistoryPanelModelDelegate {
    func didChange(sender: ChartHistoryPanelModel, score: Scope) {
        update(scope: score)
    }
}
