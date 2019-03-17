//
//  ChartGraphicView.swift
//  TelegramContest
//
//  Created by g.tokmakov on 13/03/2019.
//  Copyright © 2019 g.tokmakov. All rights reserved.
//

import UIKit

class Scope: NSObject {
    let from: CGFloat
    let to: CGFloat
    
    var lenght: CGFloat {
        return to - from
    }
    
    private let accuracy: CGFloat = 10000
    init(from: CGFloat, to: CGFloat) {
        self.from = round(from * accuracy) / accuracy
        self.to = round(to * accuracy) / accuracy
    }
}

struct StrictRange<T> {
    let from: T
    let to: T
}

fileprivate class CharGraphicLayer: CAShapeLayer {
    struct Scale {
        let width: CGFloat
        let height: CGFloat
    }
    
    lazy var dateFormatter: DateFormatter = {
        let dateFromater = DateFormatter()
        dateFromater.dateFormat = "MMM dd"
        return dateFromater
    }()
    
    lazy var yearFormatter: DateFormatter = {
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        return yearFormatter
    }()
    
    @NSManaged var scope: Scope
    @NSManaged var appearance: ChartGraphicAppearance?
    
    @NSManaged var levelsCount: Int
    @NSManaged var levelsRatio: [CGFloat] // [fromLevel, toLevel, ratio]
    @NSManaged var dates: [Int]
    @NSManaged var selectedPoint: CGFloat
    
    @NSManaged var chartsVisibility: [CGFloat]
    @NSManaged var charts: [Chart]
    @NSManaged var isAnimation: Bool
    
    override func action(forKey event: String) -> CAAction? {
        if event == #keyPath(scope) ||
            event == #keyPath(chartsVisibility) ||
            event == #keyPath(dates) ||
            event == #keyPath(levelsRatio) ||
            event == #keyPath(selectedPoint) ||
            event == #keyPath(charts) {
            setNeedsDisplay()
        }
        return super.action(forKey: event)
    }
    
    override class func needsDisplay(forKey key: String) -> Bool {
        if key == #keyPath(scope) ||
            key == #keyPath(levelsRatio) ||
            key == #keyPath(chartsVisibility) {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        setNeedsDisplay()
    }
    
    override func display() {
        var chartVisibility = isAnimation ? presentation()!.chartsVisibility : self.chartsVisibility
        let levelsRatio =  isAnimation ? presentation()!.levelsRatio : self.levelsRatio
        guard let chart = charts.first,
            let appeatance = appearance else {
                return
        }
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return
        }
        
        let timeRange = findTimeRange(chart: chart, scope: scope)
        let indexes = findIndexes(columns: chart.columns, timeRange: timeRange)
        
        let fromLevel = levelsRatio[0]
        let toLevel = levelsRatio[1]
        let ratio = levelsRatio[2]
        
        let levelDiff = toLevel - fromLevel
        let level = fromLevel + (levelDiff * ratio)
        
        let scaleByWidth = bounds.width / CGFloat(timeRange.to - timeRange.from)
        let datesHeight = draw(dates: dates, scale: Scale(width: scaleByWidth, height: 1), timeRange: timeRange, ctx: ctx, appearance: appeatance)
        let datesSpacing: CGFloat = datesHeight > 0 ? 4 : 0
        
        let height = bounds.height - datesHeight - datesSpacing
        let scaleByHeight = height / level
        let scale = Scale(width: scaleByWidth, height: scaleByHeight)
        
        // Levels
        if levelsCount > 0 {
            draw(level: fromLevel, levelsCount: levelsCount, scale: scale, height: height, alpha: 1 - ratio, ctx: ctx, appearance: appeatance)
            draw(level: toLevel, levelsCount: levelsCount, scale: scale, height: height, alpha: ratio, ctx: ctx, appearance: appeatance)
        }
        
        // Graphics
        charts.enumerated().forEach { offset, chart in
            let alpha = chartVisibility[offset]
            if alpha < 0.05 {
                return
            }
            draw(chart: chart, indexes: indexes, scale: scale, height: height, timeRange: timeRange, alpha: alpha, ctx: ctx)
        }
        
        // details view
        if selectedPoint >= 0 {
            var visibleCharts: [Chart] = []
            charts.enumerated().forEach { offset, chart in
                let alpha = chartVisibility[offset]
                if alpha > 0.05 {
                    visibleCharts.append(chart)
                }
            }
            let columns = chart.columns
            let onePointDistance = (columns[1].time - columns[0].time) / 2
            let pointCenter = timeRange.from + (Int(CGFloat(chart.time) * (selectedPoint - scope.from)))
            let searchTimeRange = StrictRange<Int>(from: pointCenter - onePointDistance, to: pointCenter + onePointDistance)
            let indexes = findIndexes(columns: columns, timeRange: searchTimeRange)
            
            draw(index: indexes.from, charts: visibleCharts, scale: scale, timeRange: timeRange, height: height, ctx: ctx, appearance: appeatance)
        }
        
        contents = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
        UIGraphicsEndImageContext()
    }
    
    private func draw(chart: Chart, indexes: StrictRange<Int>, scale: Scale, height: CGFloat, timeRange: StrictRange<Int>, alpha: CGFloat, ctx: CGContext) {
        let columns = chart.columns
        
        let column = columns[indexes.from]
        let xStartPosition = CGFloat(column.time - timeRange.from) * scale.width
        let yStartPosition = height - CGFloat(column.value) * scale.height
        
        ctx.beginPath()
        ctx.setStrokeColor(UIColor.init(tc_hex: chart.hexColor).cgColor)
        ctx.move(to: CGPoint(x: xStartPosition, y: yStartPosition))
        ctx.setAlpha(alpha)
        
        for i in (indexes.from + 1)...indexes.to {
            let column = columns[i]
            let xPosition = CGFloat(column.time - timeRange.from) * scale.width
            let yPosition = height - CGFloat(column.value) * scale.height
            ctx.setLineJoin(.round)
            ctx.addLine(to: CGPoint(x: xPosition, y: yPosition))
        }
        
        ctx.setLineWidth(lineWidth)
        ctx.strokePath()
    }
    
    private func draw(level: CGFloat, levelsCount: Int, scale: Scale, height: CGFloat, alpha: CGFloat, ctx: CGContext, appearance: ChartGraphicAppearance) {
        let levelHeight = level / CGFloat(levelsCount + 1)
        let levelColor = appearance.levelColor
        let zeroLevelColor = appearance.zeroLevelColor
        let valueColor = appearance.valueColor
        let lineWidth: CGFloat = 0.4
        
        for i in 0...levelsCount {
            ctx.beginPath()
            ctx.setStrokeColor((i == 0 ? zeroLevelColor : levelColor).cgColor)
            ctx.setAlpha(alpha)
            
            let levelHeight = CGFloat(i) * levelHeight
            let x0Position: CGFloat = 0
            let x1Position = bounds.width
            let yPosition = round(height - (levelHeight * scale.height) - (lineWidth / 2))
            ctx.move(to: CGPoint(x: x0Position, y: yPosition))
            ctx.addLine(to: CGPoint(x: x1Position, y: yPosition))
            ctx.setLineWidth(lineWidth)
            ctx.closePath()
            ctx.strokePath()
            
            let levelValue = i * (Int(level) / (levelsCount + 1))
            let attr = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: valueColor]
            let levelValueString = NSAttributedString(string: formattedString(value: levelValue), attributes: attr)
            let size = levelValueString.boundingRect(with: .zero, options: [.usesLineFragmentOrigin], context: nil).size
            let origin = CGPoint(x: 0, y: yPosition - 2 - size.height)
            levelValueString.draw(with: CGRect(origin: origin, size: size), options: [.usesLineFragmentOrigin], context: nil)
        }
    }
    
    private func draw(index: Int, charts: [Chart], scale: Scale, timeRange: StrictRange<Int>, height: CGFloat, ctx: CGContext, appearance: ChartGraphicAppearance) {
        let backgroundColor = appearance.valueDetailsColor
        
        let values = charts.map { $0.columns[index].value }
        let colors = charts.map { UIColor.init(tc_hex: $0.hexColor) }
        let time = charts[0].columns[index].time
        let date = Date.init(timeIntervalSince1970: TimeInterval(time))
        
        let dateColor = appearance.detailsDateColor
        
        let yearAttr = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13), NSAttributedString.Key.foregroundColor: dateColor]
        let yearAttrString = NSAttributedString(string: yearFormatter.string(from: date), attributes: yearAttr)
        let yearSize = yearAttrString.boundingRect(with: .zero, options: [.usesLineFragmentOrigin], context: nil)
        
        let monthDayAttr = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .bold), NSAttributedString.Key.foregroundColor: dateColor]
        let monthDayAttrString = NSAttributedString(string: dateFormatter.string(from: date), attributes: monthDayAttr)
        let monthDaySize = monthDayAttrString.boundingRect(with: .zero, options: [.usesLineFragmentOrigin], context: nil)
        
        let valueStrings = values.enumerated().map { offset, value -> NSAttributedString in
            let attr = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .bold), NSAttributedString.Key.foregroundColor: colors[offset]]
            return NSAttributedString(string: formattedString(value: value), attributes: attr)
        }
        let valueSizes = valueStrings.map { $0.boundingRect(with: .zero, options: [.usesLineFragmentOrigin], context: nil).size }
        
        var maxValueWidth: CGFloat = 0
        valueSizes.forEach { size in
            if maxValueWidth < size.width {
                maxValueWidth = size.width
            }
        }
        
        let correctedTime = time - timeRange.from
        
        let spacing: CGFloat = 6
        let dataSpacing: CGFloat = 20
        let horMargin: CGFloat = 10
        let verMargin: CGFloat = 6
        
        let valuesHeight = (CGFloat(values.count) * valueSizes[0].height) + (CGFloat(values.count - 1) * spacing)
        let dateHeight = yearSize.height + spacing + monthDaySize.height
        let containerSize = CGSize(width: (horMargin * 2) + monthDaySize.width + dataSpacing + maxValueWidth,
                                   height: (verMargin * 2) + max(valuesHeight, dateHeight))
        let horCenter = CGFloat(correctedTime) * scale.width
        
        let containerRect = CGRect(origin: .init(x: horCenter - (containerSize.width / 2), y: verMargin), size: containerSize)
        
        let lineColor = appearance.zeroLevelColor
        ctx.beginPath()
        ctx.setStrokeColor(lineColor.cgColor)
        ctx.setLineWidth(0.4)
        ctx.move(to: CGPoint(x: horCenter, y: containerRect.maxY))
        ctx.addLine(to: CGPoint(x: horCenter, y: height))
        ctx.strokePath()
        
        let pointSize = CGSize(width: 8, height: 8)
        let yValues = values.map { height - CGFloat($0) * scale.height }
        yValues.enumerated().forEach { offset, y in
            let rect = CGRect(origin: .init(x: horCenter - (pointSize.width / 2), y: y - (pointSize.height / 2)), size: pointSize)
            ctx.beginPath()
            ctx.addEllipse(in: rect)
            ctx.setFillColor(appearance.backgroundColor.cgColor)
            ctx.fillPath()
            
            ctx.beginPath()
            ctx.setLineWidth(lineWidth)
            ctx.addEllipse(in: rect)
            ctx.setStrokeColor(colors[offset].cgColor)
            ctx.strokePath()
        }
        
        let path = UIBezierPath(roundedRect: containerRect, cornerRadius: 4)
        ctx.setFillColor(backgroundColor.cgColor)
        ctx.addPath(path.cgPath)
        ctx.fillPath()
        
        let monthDayPoint = CGPoint(x: containerRect.minX + horMargin, y: containerRect.minY + verMargin)
        monthDayAttrString.draw(at: monthDayPoint)
        yearAttrString.draw(at: .init(x: monthDayPoint.x, y: monthDayPoint.y + spacing + monthDaySize.height))
        
        var verticalOffset: CGFloat = containerRect.minY + verMargin
        valueStrings.enumerated().forEach { offset, string in
            let size = valueSizes[offset]
            string.draw(at: .init(x: containerRect.maxX - horMargin - size.width, y: verticalOffset))
            verticalOffset += spacing + size.height
        }
    }
    
    private func draw(dates: [Int], scale: Scale, timeRange: StrictRange<Int>, ctx: CGContext, appearance: ChartGraphicAppearance) -> CGFloat {
        guard dates.count > 0 else { return 0 }
        let dateColor = appearance.valueColor
        
        let diff = dates[1] - dates[0]
        let dateCellWidth = CGFloat(diff) * scale.width
        let from = timeRange.from - diff
        let to = timeRange.to + diff
        var dateHeight: CGFloat = 0
        for date in dates {
            guard date >= from && date <= to else { continue }
            
            let dateString = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(date)))
            let attr = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: dateColor]
            let dateAttrString = NSAttributedString(string: String(dateString), attributes: attr)
            let size = dateAttrString.boundingRect(with: .zero, options: [.usesLineFragmentOrigin], context: nil).size
            dateHeight = size.height
            
            let x = CGFloat(date - timeRange.from) * scale.width + ((dateCellWidth - size.width) / 2)
            let y = bounds.height - size.height
            let origin = CGPoint(x: x, y: y)
            dateAttrString.draw(with: CGRect(origin: origin, size: size), options: [.usesLineFragmentOrigin], context: nil)
        }
        return dateHeight
    }
    
    private func formattedString(value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        var result = String(value)
        if value > 10000000 {
            if let string = formatter.string(for: value / 10000000) {
                result = string + "M"
            }
        }
        if value > 1000 {
            if let string = formatter.string(for: value / 1000) {
                result = string + "K"
            }
        }
        return result
    }
}

struct Level {
    let value: Int
    let index: Int
}

class ChartGraphicView: UIView {
    var appearance: ChartViewAppearance? {
        didSet {
            updateAppearance()
        }
    }
    var viewModel: ChartGraphicViewModel? {
        didSet {
            viewModel?.delegate = self
            guard let viewModel = viewModel else {
                return
            }
            chartLayer.selectedPoint = viewModel.selectedPoint ?? -1
            chartLayer.levelsCount = viewModel.levels
            chartLayer.chartsVisibility = viewModel.charts.map { $0.isHidden ? 0 : 1 }
            preparePeaks(charts: viewModel.charts)
            updateVisibleScope()
            updatePeak()
            scope = viewModel.scope
            chartLayer.charts = viewModel.charts
        }
    }
    
    fileprivate var chartLayer: CharGraphicLayer {
        return layer as! CharGraphicLayer
    }
    
    override public class var layerClass: AnyClass {
        return CharGraphicLayer.self
    }
    
    private var needUpdatePeaks: Bool = true
    
    public var scope: Scope {
        willSet(value) {
            if scope.lenght != value.lenght {
                needUpdatePeaks = true
            }
        }
        didSet {
            updateVisibleScope()
            updatePeak()
            chartLayer.scope = scope
        }
    }
    
    public var lineWidth: CGFloat = 1 {
        didSet {
            chartLayer.lineWidth = lineWidth
        }
    }
    
    override var frame: CGRect {
        willSet(value) {
            if frame.size != value.size {
                needUpdatePeaks = true
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateVisibleScope()
        updatePeak()
    }
    
    private var peaks: [Int]?
    private var levels: [Level] = []
    
    override init(frame: CGRect) {
        self.scope = Scope(from: 0, to: 1)
        super.init(frame: frame)
        
        self.chartLayer.scope = self.scope
        self.chartLayer.drawsAsynchronously = true
        self.chartLayer.selectedPoint = -1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func preparePeaks(charts: [Chart]?) {
        guard let charts = charts?.filter({ !$0.isHidden }),
            let chart = charts.first else {
                return
        }
        
        let columns = chart.columns
        var peaks: [Int] = []
        for i in 0..<columns.count {
            var value = 0
            for chart in charts {
                let currentValue = chart.columns[i].value
                if value < currentValue {
                    value = currentValue
                }
            }
            peaks.append(value)
        }
        self.peaks = peaks
        needUpdatePeaks = true
    }
    
    private func updateVisibleScope() {
        guard needUpdatePeaks, let viewModel = viewModel else {
            return
        }
        let charts = viewModel.charts.filter { !$0.isHidden }
        guard let chart = charts.first,
            let peaks = peaks else {
                return
        }
        
        let visibleLenght = Int(CGFloat(chart.time) * scope.lenght)
        let visibleTime = chart.columns.first!.time + visibleLenght
        var visibleIndexesCount = 0
        let columns = chart.columns
        for i in 0..<columns.count {
            let column = columns[i]
            if column.time >= visibleTime {
                visibleIndexesCount = i
                break
            }
        }
        
        var levels: [Level] = []
        var level = 0
        
        var localPeak = 0
        var localPeakIndex = 0
        
        var point = 0
        var screenPoints: [Int] = []
        while point < chart.columns.count - 1 {
            screenPoints.append(point)
            point += visibleIndexesCount
        }
        
        let columnsCount = chart.columns.count
        for i in screenPoints {
            localPeak = 0
            localPeakIndex = 0
            let limit = i + visibleIndexesCount
            let count = limit <= columnsCount ? visibleIndexesCount : columnsCount - i
            for j in i..<i+count {
                if localPeak < peaks[j] {
                    localPeak = peaks[j]
                    localPeakIndex = j
                }
            }
            
            if i == screenPoints.first! {
                level = calculateLevel(forPeak: localPeak, levelCount: viewModel.levels)
                levels.append(Level(value: level, index: 0))
            }
            
            if i == screenPoints.last! {
                level = calculateLevel(forPeak: localPeak, levelCount: viewModel.levels)
                levels.append(Level(value: level, index: chart.columns.count - 1))
            }
            
            if i != screenPoints.last! && i != screenPoints.first! {
                level = calculateLevel(forPeak: localPeak, levelCount: viewModel.levels)
                levels.append(Level(value: level, index: localPeakIndex))
            }
        }
        
        if levels.count > 2 {
            var previous: Level = levels.first!
            var uniqueLevels: [Level] = [previous]
            for i in 1..<levels.count {
                let level = levels[i]

                // last should not be equal with previous
                if i + 1 == levels.count - 1 {
                    if level.value != levels.last!.value {
                        uniqueLevels.append(level)
                    }
                } else if i == levels.count - 1 {
                    uniqueLevels.append(level)
                } else if level.value != previous.value {
                    uniqueLevels.append(level)
                    previous = level
                }
            }
            levels = uniqueLevels
        }
        
        self.levels = levels
        needUpdatePeaks = false
        if viewModel.shouldShowDates {
            let datesCount = Int(CGFloat(viewModel.visibleDatesCount) * CGFloat(chart.time) / CGFloat(visibleLenght))
            updateDates(datesCount: datesCount, fromTime: chart.columns.first!.time, toTime: chart.columns.last!.time)
        }
    }
    
    private func updateDates(datesCount count: Int, fromTime: Int, toTime: Int) {
        let distance = toTime - fromTime
        let timeOffset = distance / count
        let end = toTime
        var dates: [Int] = []
        var time = fromTime
        while time <= end {
            dates.append(time)
            time += timeOffset
        }
        chartLayer.dates = dates
    }
    
    private func calculateLevel(forPeak peak: Int, levelCount: Int) -> Int {
        guard levelCount > 0 else {
            return peak
        }
        let part = Int(ceil(CGFloat(peak) / CGFloat(levelCount)))
        let lenght = String(part).count
        var level = part * levelCount
        if lenght > 2 {
            let decimals = Int(pow(Double(10), Double(lenght - 2)))
            level = (part / decimals) * levelCount * decimals
        }
        return Int(CGFloat(level) * 1.1)
    }
    
    private func updatePeak(animated: Bool = false) {
        let charts = viewModel?.charts.filter { !$0.isHidden }
        guard let chart = charts?.first else {
            return
        }
        
        let timeRange = findTimeRange(chart: chart, scope: scope)
        let indexes = findIndexes(columns: chart.columns, timeRange: timeRange)
        
        var levelsRatio: [CGFloat] = [0,0,0]
        
        if let levels = targetLevels(indexes: indexes) {
            
            var ratio: CGFloat = 1
            let fromInside = levels.from.index >= indexes.from && levels.from.index <= indexes.to
            let toInside = levels.to.index >= indexes.from && levels.to.index <= indexes.to
            if fromInside && toInside {
                ratio = levels.from.value > levels.to.value ? 0 : 1
            } else if fromInside {
                ratio = 0
            } else if levels.from.index < indexes.from && levels.to.index > indexes.to {
                let left = indexes.from - levels.from.index
                let right = levels.to.index - indexes.to
                let wayWidth = left + right
                ratio = CGFloat(left) / CGFloat(wayWidth)
            }
            
            levelsRatio = [CGFloat(levels.from.value), CGFloat(levels.to.value), ratio]
        }
        
        if animated {
            chartLayer.isAnimation = true
            
            let old = chartLayer.levelsRatio
            let oldRatio = old[2]
            let oldLevel = old[2] > 0.5 ? old[1] : old[0]
            let newLevel = levelsRatio[2] > 0.5 ? levelsRatio[1] : levelsRatio[0]
            let fromLevelsRatio: [CGFloat] = [oldLevel, newLevel, oldRatio < 0.5 ? oldRatio : 0]
            let toLevelsRatio: [CGFloat] = [oldLevel, newLevel, 1]
            
            let animation = CABasicAnimation(keyPath: #keyPath(CharGraphicLayer.levelsRatio))
            animation.fromValue = fromLevelsRatio
            animation.toValue = toLevelsRatio
            animation.duration = 0.2
            animation.fillMode = .forwards
            chartLayer.add(animation, forKey: #keyPath(CharGraphicLayer.levelsRatio))
        } else {
            chartLayer.isAnimation = false
        }
        chartLayer.levelsRatio = levelsRatio
    }
    
    private func targetLevels(indexes: StrictRange<Int>) -> StrictRange<Level>? {
        var from: Level?
        var to: Level?
        for level in levels {
            if indexes.from <= level.index {
                if level.index < indexes.to {
                    from = level
                }
                break
            }
            from = level
        }
        for level in levels.reversed() {
            if level.index <= indexes.to {
                if level.index > indexes.from {
                    to = level
                }
                break
            }
            to = level
        }
        guard from != nil, to != nil else {
            return nil
        }
        return StrictRange<Level>(from: from!, to: to!)
    }
    
    private func updateAppearance() {
        guard let appearance = appearance else {
            return
        }
        backgroundColor = appearance.backgroundColor
        chartLayer.appearance = appearance.graphic
    }
}

extension ChartGraphicView: ChartGraphicViewModelDelegate {
    func updateVisibility(sender: ChartGraphicViewModel, from: [CGFloat], to: [CGFloat]) {
        chartLayer.charts = sender.charts
        preparePeaks(charts: sender.charts)
        updateVisibleScope()
        updatePeak(animated: true)
        
        chartLayer.isAnimation = true
        let animation = CABasicAnimation(keyPath: #keyPath(CharGraphicLayer.chartsVisibility))
        animation.fromValue = from
        animation.toValue = to
        animation.duration = 0.2
        animation.fillMode = .forwards
        chartLayer.add(animation, forKey: #keyPath(CharGraphicLayer.chartsVisibility))
        chartLayer.chartsVisibility = to
    }
    
    func updateScope(sender: ChartGraphicViewModel) {
        scope = sender.scope
    }
    
    func updateSelectedPoint(sender: ChartGraphicViewModel, value: CGFloat?) {
        chartLayer.selectedPoint = value ?? -1
    }
}

private func findIndexes(columns: [ChartColumn], timeRange: StrictRange<Int>) -> StrictRange<Int> {
    var fromIndex = 0
    
    for i in 1..<columns.count {
        let column = columns[i]
        if column.time <= timeRange.from {
            fromIndex = i
        } else {
            break
        }
    }
    
    var toIndex = 0
    for i in stride(from: columns.count - 1, to: 0, by: -1) {
        let column = columns[i]
        if column.time >= timeRange.to {
            toIndex = i
        } else {
            break
        }
    }
    return StrictRange<Int>(from: fromIndex, to: toIndex)
}

private func findTimeRange(chart: Chart, scope: Scope) -> StrictRange<Int> {
    let columns = chart.columns
    let fromOffset = Int(CGFloat(chart.time) * scope.from)
    let toOffset = Int(CGFloat(chart.time) * (1 - scope.to))
    return StrictRange<Int>(from: columns.first!.time + fromOffset,
                                     to: columns.last!.time - toOffset)
}
