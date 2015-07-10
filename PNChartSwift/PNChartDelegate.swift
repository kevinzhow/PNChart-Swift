//
//  PNChartDelegate.swift
//  PNChart-Swift
//
//  Created by kevinzhow on 6/5/14.
//  Copyright (c) 2014 Catch Inc. All rights reserved.
//

import UIKit

public protocol PNChartDelegate {
    /**
    * When user click on the chart line
    *
    */
    func userClickedOnLinePoint(point: CGPoint, lineIndex:Int)
    
    /**
    * When user click on the chart line key point
    *
    */
    func userClickedOnLineKeyPoint(point: CGPoint, lineIndex:Int, keyPointIndex:Int)
    
    /**
    * When user click on a chart bar
    *
    */
    func userClickedOnBarChartIndex(barIndex:Int)
}