//
//  PNGenericChart.swift
//  PNChartSwift
//
//  Created by YiChen Zhou on 12/27/16.
//  Copyright © 2016 YiChen Zhou. All rights reserved.
//

import UIKit

class PNGenericChart: UIView {
    var hasLegend: Bool!
    var legendPosition: PNLegendPosition!
    var legendStyle: PNLegendItemStyle!
    var legendFont: UIFont!
    var legendFontColor: UIColor!
    var labelRowsInSerialMode: Int!
    var displayAnimation: Bool = false
    
    func setupDefaultValues() {
        hasLegend = true
        legendPosition = .Bottom
        legendStyle = .Stacked
        labelRowsInSerialMode = 1
        displayAnimation = true
    }
    
    func getLegendWIthMaxWidth(maxWidth: Float) -> UIView! {
        //self.doesNotRecognizeSelector(_cmd)
        return nil
    }
    
    func setLabelRowsInSerialMode(num: Int) {
        if legendStyle == .Serial {
            labelRowsInSerialMode = num
        } else {
            labelRowsInSerialMode = 1
        }
    }
}

extension PNGenericChart {
    enum PNLegendPosition: Int {
        case Top = 0
        case Bottom = 1
        case Left = 2
        case Right = 3
    }
    
    enum PNLegendItemStyle: Int {
        case Stacked = 0
        case Serial = 1
    }
}
