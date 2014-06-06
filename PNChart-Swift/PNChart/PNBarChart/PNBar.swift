//
//  PNBar.swift
//  PNChart-Swift
//
//  Created by kevinzhow on 6/6/14.
//  Copyright (c) 2014 Catch Inc. All rights reserved.
//

import UIKit
import QuartzCore

class PNBar:UIView {
    var grade: CGFloat = 0.0
    var chartLine: CAShapeLayer!
    var barColor: UIColor = PNGreenColor
    var barRadius: CGFloat = 0.0
    
    func rollBack() {
        
    }
    
    init(frame: CGRect)
    {
        super.init(frame: frame)
        chartLine              = CAShapeLayer()
        chartLine.lineCap      = kCALineCapButt
        chartLine.fillColor    = UIColor.whiteColor().CGColor
        chartLine.lineWidth    = frame.size.width
        chartLine.strokeEnd    = 0.0
        clipsToBounds      = true
        layer.addSublayer(chartLine)
        barRadius = 2.0
    }

}
