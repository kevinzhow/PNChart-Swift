//
//  PNLineChartData.swift
//  PNChart-Swift
//
//  Created by kevinzhow on 6/5/14.
//  Copyright (c) 2014 Catch Inc. All rights reserved.
//

import UIKit

class PNLineChartDataItem{
    var y:CGFloat = 0.0
}


class PNLineChartData{
    
    enum PNLineChartPointStyle:Int{
        case PNLineChartPointStyleNone = 0
        case PNLineChartPointStyleCycle
        case PNLineChartPointStyleTriangle
        case PNLineChartPointStyleSquare
    }

    /**
    *  if PNLineChartPointStyle is cycle, inflexionPointWidth equal cycle's diameter
    *  if PNLineChartPointStyle is square, that means the foundation is square with
    *  inflexionPointWidth long
    */
    
    var getData = ({(index: Int) -> PNLineChartDataItem in
        return PNLineChartDataItem()
    })
    
    var inflexionPointStyle:PNLineChartPointStyle = PNLineChartPointStyle.PNLineChartPointStyleNone
    var color:UIColor = UIColor.grayColor()
    var itemCount:Int = 0
    var lineWidth:CGFloat = 2.0
    var inflexionPointWidth:CGFloat = 6.0
}