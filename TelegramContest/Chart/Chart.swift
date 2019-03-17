//
//  Chart.swift
//  TelegramContest
//
//  Created by g.tokmakov on 18/03/2019.
//  Copyright © 2019 g.tokmakov. All rights reserved.
//

import Foundation

struct ChartColumn {
    let time: Int
    let value: Int
    
    static func == (lhs: ChartColumn, rhs: ChartColumn) -> Bool {
        return lhs.time == lhs.value && lhs.value == rhs.value
    }
}

class Chart: NSObject, NSCopying {
    let time: Int
    let columns: [ChartColumn]
    let name: String
    let hexColor: String
    var isHidden: Bool
    
    init(time: Int, columns: [ChartColumn], name: String, hexColor: String, isHidden: Bool = false) {
        self.time = time
        self.columns = columns
        self.name = name
        self.hexColor = hexColor
        self.isHidden = isHidden
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return Chart(time: time, columns: columns, name: name, hexColor: hexColor)
    }
}

class ChartParser {
    class func parse(data: [[String: Any]]) -> [[Chart]]? {
        return data.compactMap { element -> [Chart]? in
            guard let names = element["names"] as? [String: String],
                let colorsByName = element["colors"] as? [String: String],
                let columnsData = element["columns"] as? [[Any]],
                let columnsByName = parseColumns(data: columnsData) else {
                    return nil
            }
            
            var charts = names.compactMap { key, name -> Chart? in
                guard let columns = columnsByName[key],
                    let color = colorsByName[key] else {
                        return nil
                }
                let from = columns.first!
                let to = columns.last!
                return Chart(time: to.time - from.time, columns: columns, name: name, hexColor: color)
            }
            charts.sort(by: { $0.name < $1.name })
            return charts
        }
    }
    
    class func parseColumns(data: [[Any]]) -> [String: [ChartColumn]]? {
        guard data.count > 2 else {
            return nil
        }
        
        let valueCount = data.first!.count
        guard valueCount > 0 else {
            return nil
        }
        
        for values in data {
            guard values.count == valueCount else {
                return nil
            }
        }
        
        let xValues = data.first!
        var columns: [String: [ChartColumn]] = [:]
        
        for i in 1..<data.count {
            let yValues = data[i]
            guard let name = yValues[0] as? String else {
                return nil
            }
            
            var column: [ChartColumn] = []
            for j in 1..<yValues.count {
                guard let x = xValues[j] as? Int, let y = yValues[j] as? Int else {
                    return nil
                }
                column.append(ChartColumn(time: x, value: y))
            }
            columns[name] = column
        }
        return columns
    }
}
