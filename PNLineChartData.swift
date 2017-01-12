//
//  PNLineChartData.swift
//  PNChartSwift
//
//  Created by YiChen Zhou on 11/10/16.
//  Copyright © 2016 YiChen Zhou. All rights reserved.
//

import UIKit

public class PNLineChartData {
    public var getData = {
        (index: Int) -> PNLineChartDataItem in
        return PNLineChartDataItem()
    }
    
    public var inflexPointStyle = PNLineChartPointStyle.None
    public var color: UIColor = UIColor.gray
    public var itemCount: Int = 0
    public var lineWidth: CGFloat = 2.0
    public var inflexionPointWidth: CGFloat = 6.0
    
    public init() { }
}

extension PNLineChartData {
    public enum PNLineChartPointStyle: Int {
        case None = 0
        case Cycle
        case Triangle
        case Square
    }
}
