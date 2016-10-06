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
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
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
            self.chartLine.add(pathAnimation, forKey:"strokeEndAnimation")
            self.chartLine.strokeEnd = 1.0
            
            
            delay(self.startAnimationTime, closure: {
                
                self.chartLine.add(pathAnimation, forKey:"strokeEndAnimation")
                let progressline:UIBezierPath = UIBezierPath()
                progressline.move(to: CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height))
                progressline.addLine(to: CGPoint(x: self.frame.size.width / 2.0, y: (1 - self.grade) * self.frame.size.height))
                progressline.lineWidth = 1.0
                progressline.lineCapStyle = CGLineCap.square
                self.chartLine.path = progressline.cgPath
                self.chartLine.strokeColor = self.barColor.cgColor
                
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
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions(), animations: ({() -> Void in
                self.chartLine.strokeColor = UIColor.clear.cgColor
            }), completion: ({(Bool) -> Void in
                
            }) )
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        chartLine              = CAShapeLayer()
        chartLine.lineCap      = kCALineCapButt
        chartLine.fillColor    = UIColor.white.cgColor
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
    
    override func draw(_ rect: CGRect)
    {
        //Draw BG
        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        context.setFillColor((self.backgroundColor?.cgColor)!)
        context.fill(rect)
    }

}
