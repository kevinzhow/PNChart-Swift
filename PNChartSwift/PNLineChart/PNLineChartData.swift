//
//  PNLineChartData.swift
//  PNChart-Swift
//
//  Created by kevinzhow on 6/5/14.
//  Copyright (c) 2014 Catch Inc. All rights reserved.
//

import UIKit

public class PNLineChartDataItem{
    var y:CGFloat = 0.0

    public init(){
    }

    public init(y : CGFloat){
        self.y = y;
    }
}


public  class PNLineChartData{
    
    public enum PNLineChartPointStyle:Int{
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
    
    public var getData = ({(index: Int) -> PNLineChartDataItem in
        return PNLineChartDataItem()
    })
    
    public var inflexionPointStyle:PNLineChartPointStyle = PNLineChartPointStyle.PNLineChartPointStyleNone
    public var color:UIColor = UIColor.grayColor()
    public var itemCount:Int = 0
    public var lineWidth:CGFloat = 2.0
    public var inflexionPointWidth:CGFloat = 6.0
    
    public init(){
    
    }
}