//
//  ChartHistoryPanel.swift
//  TelegramContest
//
//  Created by g.tokmakov on 13/03/2019.
//  Copyright © 2019 g.tokmakov. All rights reserved.
//

import UIKit

let arrowPathWidth: CGFloat = 16

class RangeLayer: CALayer {
    override func layoutSublayers() {
        super.layoutSublayers()
        setNeedsDisplay()
    }
    
    override func action(forKey event: String) -> CAAction? {
        if event == #keyPath(borderColor) {
            setNeedsDisplay()
        }
        return super.action(forKey: event)
    }
    
    override func display() {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        ctx.setFillColor(borderColor ?? UIColor.gray.cgColor)
        
        let pathWidth: CGFloat = arrowPathWidth
        let leftRect = CGRect(origin: .zero, size: .init(width: pathWidth, height: bounds.height))
        let leftPath = UIBezierPath(rect: leftRect)
        ctx.addPath(leftPath.cgPath)
        ctx.fillPath()
        
        let rightRect = CGRect(origin: .init(x: bounds.width - pathWidth, y: 0), size: .init(width: pathWidth, height: bounds.height))
        let rightPath = UIBezierPath(rect: rightRect)
        ctx.addPath(rightPath.cgPath)
        ctx.fillPath()
        
        
        let lineWidth: CGFloat = 2
        let arrowWidth: CGFloat = 5
        let arrowHeight: CGFloat = 14
        let arrowMinY = leftRect.midY - (arrowHeight / 2)
        let arrowMidY = leftRect.midY
        let arrowMaxY = arrowMinY + arrowHeight
        
        ctx.setLineWidth(lineWidth)
        ctx.setStrokeColor(UIColor.white.cgColor)
        ctx.setLineJoin(.round)

        ctx.beginPath()
        ctx.move(to: CGPoint(x: leftRect.midX + (arrowWidth / 2), y: arrowMinY))
        ctx.addLine(to: CGPoint(x: leftRect.midX - (arrowWidth / 2), y: arrowMidY))
        ctx.addLine(to: CGPoint(x: leftRect.midX + (arrowWidth / 2), y: arrowMaxY))
        ctx.strokePath()
        
        ctx.beginPath()
        ctx.move(to: CGPoint(x: rightRect.midX - (arrowWidth / 2), y: arrowMinY))
        ctx.addLine(to: CGPoint(x: rightRect.midX + (arrowWidth / 2), y: arrowMidY))
        ctx.addLine(to: CGPoint(x: rightRect.midX - (arrowWidth / 2), y: arrowMaxY))
        ctx.strokePath()
        
        contents = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
        UIGraphicsEndImageContext()
    }
}

class RangeView: UIView {
    override public class var layerClass: AnyClass {
        return RangeLayer.self
    }
    
    init() {
        super.init(frame: .zero)
        self.configureViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        backgroundColor = .clear
        layer.masksToBounds = true
        layer.borderWidth = 1.4
        layer.cornerRadius = 2
    }
}

class ChartHistoryPanel: UIView {
    var appearance: ChartNavigationViewAppearance? {
        didSet {
            updateAppearance()
            chartGraphicView.appearance = appearance?.chart
        }
    }
    private let chartGraphicView = ChartGraphicView()
    private let rangeView = RangeView()
    private let fadeView = UIView()
    
    private var ignorePan: Bool = false
    private var updateJustFrom: Bool = false
    private var updateJustTo: Bool = false
    private var catchDiff: CGFloat = 0
    
    var viewModel: ChartHistoryPanelModel? {
        didSet {
            chartGraphicView.viewModel = viewModel?.graphicViewModel
            chartGraphicView.setNeedsDisplay()
            viewModel?.viewDelegate = self
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateRangeView()
    }
    
    init() {
        super.init(frame: .zero)
        self.configureViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        addSubview(chartGraphicView)
        chartGraphicView.frame = bounds
        chartGraphicView.autoresizingMask = [.flexibleWidth, .flexibleHeight]        
        
        addSubview(fadeView)
        fadeView.frame = bounds
        fadeView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(rangeView)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        addGestureRecognizer(pan)
    }
    
    @objc private func handlePan(sender: UIPanGestureRecognizer) {
        guard let viewModel = viewModel else {
            return
        }
        let value = sender.location(in: self).x / bounds.width
        switch sender.state {
        case .began:
            let catchRange = arrowPathWidth / bounds.width
            if value >= viewModel.from - (catchRange / 2) && value <= viewModel.from + (catchRange * 1.5) {
                updateJustFrom = true
            } else if value >= viewModel.to - (catchRange * 1.5) && value <= viewModel.to + (catchRange / 2) {
                updateJustTo = true
            } else if value < viewModel.from || value > viewModel.to {
                ignorePan = true
            } else {
                let middle = (viewModel.to + viewModel.from) / 2
                catchDiff = middle - value
            }
        case .ended: fallthrough
        case .failed: fallthrough
        case .cancelled:
            updateJustFrom = false
            updateJustTo = false
            ignorePan = false
            return
        default: break
        }
        
        if updateJustFrom {
            viewModel.change(from: value)
        } else if updateJustTo {
            viewModel.change(to: value)
        } else if !ignorePan {
            let half = (viewModel.to - viewModel.from) / 2
            let from = value + catchDiff - half
            let to = half + value + catchDiff
            viewModel.change(from: from, to: to)
        }
    }
    
    private func updateRangeView() {
        guard let viewModel = viewModel else {
            return
        }
        
        let height = rangeView.layer.borderWidth * 2 + bounds.height
        rangeView.frame = CGRect(origin: CGPoint(x: bounds.width * viewModel.from, y: -rangeView.layer.borderWidth),
                                 size: CGSize(width: bounds.width * (viewModel.to - viewModel.from), height: height))
        let mask = CAShapeLayer()
        let path = CGMutablePath()
        path.addRect(fadeView.bounds)
        path.addRect(rangeView.frame)
        
        mask.path = path
        mask.fillRule = .evenOdd
        
        fadeView.layer.mask = mask
    }
    
    private func updateAppearance() {
        guard let appearance = appearance else {
            return
        }
        backgroundColor = appearance.backgroundColor
        fadeView.backgroundColor = appearance.fadeColor.withAlphaComponent(0.6)
        rangeView.layer.borderColor = appearance.rangeBorderColor.withAlphaComponent(0.9).cgColor    
    }
}

extension ChartHistoryPanel: ChartHistoryPanelModelViewDelegate {
    func updateUI(sender: ChartHistoryPanelModel) {
        updateRangeView()        
    }
}
