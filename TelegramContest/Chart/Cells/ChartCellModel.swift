//
//  ChartCellModel.swift
//  TelegramContest
//
//  Created by g.tokmakov on 13/03/2019.
//  Copyright © 2019 g.tokmakov. All rights reserved.
//

import UIKit

class ChartCellModel {
    let startedScore = Scope(from: 0.7, to: 1)
    let graphicViewModel: ChartGraphicViewModel
    let historyViewModel: ChartHistoryPanelModel
    private var selectedGraphicPoint: CGFloat?
    
    init(charts: [Chart]) {
        self.graphicViewModel = ChartGraphicViewModel(charts: charts.map({ $0.copy() as! Chart }), levels: 5, shouldShowDates: true)
        self.historyViewModel = ChartHistoryPanelModel(charts: charts.map({ $0.copy() as! Chart }))
        self.historyViewModel.delegate = self.graphicViewModel
        self.graphicViewModel.update(scope: self.startedScore)
    }
    
    func updateGraphicVisibility(index: Int, isHidden: Bool) {
        graphicViewModel.updateChartVisibility(index: index, isHidden: isHidden)
        historyViewModel.updateChartVisibility(index: index, isHidden: isHidden)
    }
    
    func didSelectGraphicPoint(value: CGFloat) {
        var newPoint = false
        if let oldValue = selectedGraphicPoint {
            if value < oldValue - 0.05 || value > oldValue + 0.05 {
                newPoint = true
            }
        } else {
            newPoint = true
        }
        
        if newPoint {
            let scope = graphicViewModel.scope
            let relatedPoint = scope.lenght * value
            graphicViewModel.selectedPoint = scope.from + relatedPoint
            selectedGraphicPoint = value
        } else {
            graphicViewModel.selectedPoint = nil
            selectedGraphicPoint = nil
        }
    }
}
