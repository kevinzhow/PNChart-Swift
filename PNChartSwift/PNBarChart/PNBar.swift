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
    
    // Used to delay each bar animation for waterfall effect
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    // Time before bar starts animating
    var startAnimationTime = 0.0
    
    var grade: CGFloat = 0.0 {
        didSet {
            
            UIGraphicsBeginImageContext(self.frame.size)
            
            let pathAnimation: CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
            pathAnimation.duration = 1.0
            pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            pathAnimation.fromValue = 0.0
            pathAnimation.toValue = 1.0
            self.chartLine.addAnimation(pathAnimation, forKey:"strokeEndAnimation")
            self.chartLine.strokeEnd = 1.0
            
            
            delay(self.startAnimationTime, closure: {
                
                self.chartLine.addAnimation(pathAnimation, forKey:"strokeEndAnimation")
                let progressline:UIBezierPath = UIBezierPath()
                progressline.moveToPoint(CGPointMake(self.frame.size.width / 2.0, self.frame.size.height))
                progressline.addLineToPoint(CGPointMake(self.frame.size.width / 2.0, (1 - self.grade) * self.frame.size.height))
                progressline.lineWidth = 1.0
                progressline.lineCapStyle = CGLineCap.Square
                self.chartLine.path = progressline.CGPath
                self.chartLine.strokeColor = self.barColor.CGColor
                
            })
            
            UIGraphicsEndImageContext()

        }
    }
    var chartLine: CAShapeLayer!
    var barColor: UIColor = PNGreenColor
    var barRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = barRadius
        }
    }
    
    func rollBack() {
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: ({() -> Void in
                self.chartLine.strokeColor = UIColor.clearColor().CGColor
            }), completion: ({(Bool) -> Void in
                
            }) )
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        chartLine              = CAShapeLayer()
        chartLine.lineCap      = kCALineCapButt
        chartLine.fillColor    = UIColor.whiteColor().CGColor
        chartLine.lineWidth    = frame.size.width
        chartLine.strokeEnd    = 0.0
        clipsToBounds      = true
        backgroundColor = PNLightGreyColor
        layer.addSublayer(chartLine)
        barRadius = 2.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect)
    {
        //Draw BG
        let context: CGContextRef = UIGraphicsGetCurrentContext()!
        
        CGContextSetFillColorWithColor(context, self.backgroundColor?.CGColor)
        CGContextFillRect(context, rect)
    }

}
