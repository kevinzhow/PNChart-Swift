//
//  PNBar.swift
//  PNChartSwift
//
//  Created by YiChen Zhou on 12/29/16.
//  Copyright © 2016 YiChen Zhou. All rights reserved.
//

import UIKit

class PNBar: UIView {

    // Time brfore bar starts to animate
    var startAnimationTime: Double = 0
    var chartLine: CAShapeLayer = {
        return CAShapeLayer()
        
    }()
    
    var barColor = PNFreshGreen
    var barRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = self.barRadius
        }
    }
    
    var grade: CGFloat = 0 {
        didSet {
            UIGraphicsBeginImageContext(self.frame.size)
            let path = CABasicAnimation(keyPath: "strokeEnd")
            path.duration = 1
            path.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            path.fromValue = 0
            path.toValue = 1
            self.chartLine.add(path, forKey: "strokeEndAnimation")
            self.chartLine.strokeEnd = 1
            self.delay(delay: self.startAnimationTime, closure: {
                () -> () in
                self.chartLine.add(path, forKey: "strokeEndAnimation")
                let progressLine = UIBezierPath()
                progressLine.move(to: CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height))
                progressLine.addLine(to: CGPoint(x: self.frame.size.width / 2.0, y: (1 - self.grade) * self.frame.size.height))
                progressLine.lineCapStyle = .square
                self.chartLine.path = progressLine.cgPath
                self.chartLine.strokeColor = self.barColor.cgColor
            })
            UIGraphicsEndImageContext()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.chartLine = CAShapeLayer()
        self.chartLine.lineCap = kCALineCapButt
        self.chartLine.fillColor = UIColor.white.cgColor
        self.chartLine.lineWidth = self.frame.size.width
        self.chartLine.strokeEnd = 0
        self.clipsToBounds = true
        self.backgroundColor = PNLightGrey
        self.layer.addSublayer(self.chartLine)
        self.barRadius = 10
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        // Draw BackGround
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor((self.backgroundColor?.cgColor)!)
        context.addRect(rect)
    }
    
    func delay(delay: Double, closure: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            () -> () in
            closure()
        }
    }
    
    func rollBack() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: ({
            self.chartLine.strokeColor = UIColor.clear.cgColor
        }), completion: nil)
    }
}
