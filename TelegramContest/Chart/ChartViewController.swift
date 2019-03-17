//
//  ChartViewController.swift
//  TelegramContest
//
//  Created by g.tokmakov on 13/03/2019.
//  Copyright © 2019 g.tokmakov. All rights reserved.
//

import UIKit

private let cellLayoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)

class ChartViewController: UIViewController {
    private let viewModel: ChartViewModel
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var sections: [[Any]] = []
    
    init(viewModel: ChartViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        viewModel.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Telegram Contest"
        
        loadCharts()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ChartSwitchCell.self, forCellReuseIdentifier: ChartSwitchCell.tc_reuseIdentifier())
        tableView.register(ChartCell.self, forCellReuseIdentifier: ChartCell.tc_reuseIdentifier())
        tableView.register(SwitchCell.self, forCellReuseIdentifier: SwitchCell.tc_reuseIdentifier())
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(tableView)
        
        updateAppearance()
    }
    
    private func loadCharts() {
        let name = "chart_data"
        guard let filePath = Bundle.main.url(forResource: name, withExtension: "json") else {
            return
        }
        
        do {
            let data = try Data(contentsOf: filePath)
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]],
                let chartsSet = ChartParser.parse(data: json) else {
                    return
            }
            var sections = chartsSet.map({ charts -> [Any] in
                var viewModels: [Any] = []
                
                let chartCellModel = ChartCellModel(charts: charts)
                let chartSwitchModels = charts.enumerated().map({ offset, chart -> Any in
                    return ChartSwitchCellModel(title: chart.name, color: chart.hexColor, shouldShowSeparator: offset < charts.count - 1, action: { selected in
                        chartCellModel.updateGraphicVisibility(index: offset, isHidden: !selected)
                    })
                })
                
                viewModels.append(chartCellModel)
                viewModels.append(contentsOf: chartSwitchModels)
                return viewModels
            })
            
            sections.append([viewModel.switchCellModel])
            self.sections = sections
        } catch {
            return
        }
    }
    
    private func updateAppearance() {
        let appearance = viewModel.appearance
        tableView.backgroundColor = appearance.viewController.backgroundColor
        tableView.separatorColor = appearance.viewController.separatorColor
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = appearance.viewController.navigationBackgroundColor
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : appearance.viewController.titleColor
        ]
        
        if let navigationController = navigationController as? NavigationViewController {
            navigationController.statusBarStyle = appearance.viewController.statusBarStyle
            navigationController.setNeedsStatusBarAppearanceUpdate()
        }
    }
}

extension ChartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = sections[indexPath.section][indexPath.row]
        if model is ChartSwitchCellModel {
            return 50
        } else if model is ChartCellModel {
            return 400
        } else if model is SwitchCellModel {
            return 50
        }
        return 0
    }
}

extension ChartViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = sections[indexPath.section][indexPath.row]
        if let cellViewModel = model as? ChartSwitchCellModel {
            let cell = tableView.dequeueReusableCell(withIdentifier: ChartSwitchCell.tc_reuseIdentifier(), for: indexPath) as! ChartSwitchCell
            cell.appearance = viewModel.appearance.chartSwitchCell
            cell.viewModel = cellViewModel
            cell.contentView.layoutMargins = cellLayoutMargins
            return cell
        } else if let cellViewModel = model as? ChartCellModel {
            let cell = tableView.dequeueReusableCell(withIdentifier: ChartCell.tc_reuseIdentifier(), for: indexPath) as! ChartCell
            cell.appearance = viewModel.appearance.chartCell
            cell.viewModel = cellViewModel
            cell.contentView.layoutMargins = cellLayoutMargins
            return cell
        } else if let cellViewModel = model as? SwitchCellModel {
            let cell = tableView.dequeueReusableCell(withIdentifier: SwitchCell.tc_reuseIdentifier(), for: indexPath) as! SwitchCell
            cell.appearance = viewModel.appearance.switchCell
            cell.viewModel = cellViewModel
            cell.contentView.layoutMargins = cellLayoutMargins
            return cell
        }
        return UITableViewCell()
    }        
}

extension ChartViewController: ChartViewModelDelegate {
    func updateUI(sender: ChartViewModel) {
        tableView.reloadData()
        updateAppearance()
    }
}
