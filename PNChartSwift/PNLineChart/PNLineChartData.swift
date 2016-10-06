//
//  PNLineChartData.swift
//  PNChart-Swift
//
//  Created by kevinzhow on 6/5/14.
//  Copyright (c) 2014 Catch Inc. All rights reserved.
//

import UIKit

open class PNLineChartDataItem{
    var y:CGFloat = 0.0

    public init(){
    }

    public init(y : CGFloat){
        self.y = y;
    }
}


open  class PNLineChartData{
    
    public enum PNLineChartPointStyle:Int{
        case pnLineChartPointStyleNone = 0
        case pnLineChartPointStyleCycle
        case pnLineChartPointStyleTriangle
        case pnLineChartPointStyleSquare
    }

    /**
    *  if PNLineChartPointStyle is cycle, inflexionPointWidth equal cycle's diameter
    *  if PNLineChartPointStyle is square, that means the foundation is square with
    *  inflexionPointWidth long
    */
    
    open var getData = ({(index: Int) -> PNLineChartDataItem in
        return PNLineChartDataItem()
    })
    
    open var inflexionPointStyle:PNLineChartPointStyle = PNLineChartPointStyle.pnLineChartPointStyleNone
    open var color:UIColor = UIColor.gray
    open var itemCount:Int = 0
    open var lineWidth:CGFloat = 2.0
    open var inflexionPointWidth:CGFloat = 6.0
    
    public init(){
    
    }
}
