//
//  Appearance.swift
//  TelegramContest
//
//  Created by g.tokmakov on 24/03/2019.
//  Copyright © 2019 g.tokmakov. All rights reserved.
//

import UIKit

enum ColorScheme {
    case base
    case night
}

private let black = UIColor.black
private let white = UIColor.white

private let fogGray = UIColor(tc_hex: "#CBD4DD")
private let fogBlue = UIColor(tc_hex: "#384657")
private let valueGray = UIColor(tc_hex: "#A0A0A0")
private let valueBlue = UIColor(tc_hex: "#606D7C")
private let clearBlue = UIColor(tc_hex: "#327EDD")
private let valueDetailsGray = UIColor(tc_hex: "#F5F5FA")
private let valueDetailsBlue = UIColor(tc_hex: "#1D2836")
private let detailsDateGray = UIColor(tc_hex: "#717171")
private let detailsDateBlue = white
private let ghostGray = UIColor.init(tc_hex: "#F0F0F0")
private let ghostBlue = UIColor.init(tc_hex: "#1D2733")
private let darkGray = UIColor.init(tc_hex: "#D0D0D0")
private let foneGray = UIColor.init(tc_hex: "#F0F0F0")
private let grayShadow = UIColor.init(tc_hex: "#F5F5F5")
private let blueShadow = UIColor.init(tc_hex: "#1F2A39")
private let darkBlue = UIColor.init(tc_hex: "#1A222C")
private let nightBlue = UIColor.init(tc_hex: "#24303F")

class CellAppearance {
    let backgroundColor: UIColor
    
    init(backgroundColor: UIColor) {
        self.backgroundColor = backgroundColor
    }
}

class ChartCellAppearance: CellAppearance {
    let chart: ChartViewAppearance
    let chartNavigation: ChartNavigationViewAppearance
    
    init(backgroundColor: UIColor, chart: ChartViewAppearance, chartNavigation: ChartNavigationViewAppearance) {
        self.chart = chart
        self.chartNavigation = chartNavigation
        super.init(backgroundColor: backgroundColor)
    }
}

class ChartSwitchCellAppearance: CellAppearance {
    let titleColor: UIColor
    let separatorColor: UIColor
    
    init(backgroundColor: UIColor, titleColor: UIColor, separatorColor: UIColor) {
        self.titleColor = titleColor
        self.separatorColor = separatorColor
        super.init(backgroundColor: backgroundColor)
    }
}

class SwitchCellAppearance: CellAppearance {
    let titleColor: UIColor
    
    init(backgroundColor: UIColor, titleColor: UIColor) {
        self.titleColor = titleColor
        super.init(backgroundColor: backgroundColor)
    }
}

class ChartViewAppearance: CellAppearance {
    let graphic: ChartGraphicAppearance
    
    init(backgroundColor: UIColor, graphic: ChartGraphicAppearance) {
        self.graphic = graphic
        super.init(backgroundColor: backgroundColor)
    }
}

class ChartNavigationViewAppearance: CellAppearance {
    let chart: ChartViewAppearance
    let fadeColor: UIColor
    let rangeBorderColor: UIColor
    
    init(backgroundColor: UIColor, fadeColor: UIColor, rangeBorderColor: UIColor, chart: ChartViewAppearance) {
        self.chart = chart
        self.rangeBorderColor = rangeBorderColor
        self.fadeColor = fadeColor
        super.init(backgroundColor: backgroundColor)
    }
}

class ChartGraphicAppearance: NSObject {
    let levelColor: UIColor
    let zeroLevelColor: UIColor
    let valueColor: UIColor
    let valueDetailsColor: UIColor
    let detailsDateColor: UIColor
    let backgroundColor: UIColor
    
    init(levelColor: UIColor, zeroLevelColor: UIColor, valueColor: UIColor, valueDetailsColor: UIColor, detailsDateColor: UIColor, backgroundColor: UIColor) {
        self.levelColor = levelColor
        self.zeroLevelColor = zeroLevelColor
        self.valueColor = valueColor
        self.valueDetailsColor = valueDetailsColor
        self.detailsDateColor = detailsDateColor
        self.backgroundColor = backgroundColor
        super.init()
    }
}

struct ViewControllerAppearance {
    let backgroundColor: UIColor
    let navigationBackgroundColor: UIColor
    let statusBarStyle: UIStatusBarStyle
    let titleColor: UIColor
    let separatorColor: UIColor
}

struct Appearance {
    let viewController: ViewControllerAppearance
    let chartCell: ChartCellAppearance
    let chartSwitchCell: ChartSwitchCellAppearance
    let switchCell: SwitchCellAppearance
}

struct AppearanceBuilder {
    static func build(scheme: ColorScheme) -> Appearance {
        switch scheme {
        case .base:
            return baseAppearance()
        case .night:
            return nightAppearance()
        }
    }
    
    static func baseAppearance() -> Appearance {
        let graphic = ChartGraphicAppearance(levelColor: ghostGray,
                                             zeroLevelColor: darkGray,
                                             valueColor: valueGray,
                                             valueDetailsColor: valueDetailsGray,
                                             detailsDateColor: detailsDateGray,
                                             backgroundColor: white)
        let chart = ChartViewAppearance(backgroundColor: white, graphic: graphic)
        let chartNavigation = ChartNavigationViewAppearance(backgroundColor: white, fadeColor: grayShadow, rangeBorderColor: fogGray, chart: chart)
        let chartCell = ChartCellAppearance(backgroundColor: white, chart: chart, chartNavigation: chartNavigation)
        let chartSwitchCell = ChartSwitchCellAppearance(backgroundColor: white, titleColor: black, separatorColor: foneGray)
        let switchCell = SwitchCellAppearance(backgroundColor: white, titleColor: clearBlue)
        let viewController = ViewControllerAppearance(backgroundColor: foneGray,
                                                      navigationBackgroundColor: white,
                                                      statusBarStyle: .default,
                                                      titleColor: black,
                                                      separatorColor: darkGray)
        return Appearance(viewController: viewController, chartCell: chartCell, chartSwitchCell: chartSwitchCell, switchCell: switchCell)
    }
    
    static func nightAppearance() -> Appearance {
        let graphic = ChartGraphicAppearance(levelColor: ghostBlue,
                                             zeroLevelColor: darkBlue,
                                             valueColor: valueBlue,
                                             valueDetailsColor: valueDetailsBlue,
                                             detailsDateColor: detailsDateBlue,
                                             backgroundColor: nightBlue)
        let chart = ChartViewAppearance(backgroundColor: nightBlue, graphic: graphic)
        let chartNavigation = ChartNavigationViewAppearance(backgroundColor: nightBlue, fadeColor: blueShadow, rangeBorderColor: fogBlue, chart: chart)
        let chartCell = ChartCellAppearance(backgroundColor: nightBlue, chart: chart, chartNavigation: chartNavigation)
        let chartSwitchCell = ChartSwitchCellAppearance(backgroundColor: nightBlue, titleColor: white, separatorColor: darkBlue)
        let switchCell = SwitchCellAppearance(backgroundColor: nightBlue, titleColor: clearBlue)
        let viewController = ViewControllerAppearance(backgroundColor: darkBlue,
                                                      navigationBackgroundColor: nightBlue,
                                                      statusBarStyle: .lightContent,
                                                      titleColor: white,
                                                      separatorColor: darkBlue)
        return Appearance(viewController: viewController, chartCell: chartCell, chartSwitchCell: chartSwitchCell, switchCell: switchCell)
    }
}
