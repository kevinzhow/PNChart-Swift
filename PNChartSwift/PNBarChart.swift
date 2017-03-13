//
//  PNBarChart.swift
//  PNChartSwift
//
//  Created by YiChen Zhou on 12/29/16.
//  Copyright © 2016 YiChen Zhou. All rights reserved.
//

import UIKit

class PNBarChart: UIView {
    
    var bars = NSMutableArray()
    var xLabelWidth: CGFloat!
    var yValueMax: CGFloat!
    var strokeColor = PNGreen
    var strokeColors: Array<Any>!
    var xLabelHeight: CGFloat = 11.0
    var yLabelHeight: CGFloat = 20.0
    
    var labels: NSMutableArray = []
    
    var xLabels = [String]() {
        didSet {
            if showLabel {
                xLabelWidth = (self.frame.size.width - chartMargin * 2.0) / CGFloat(xLabels.count)
            }
        }
    }
    
    var yLabels = [String]()
    var yValues = [CGFloat]() {
        didSet {
            if yMaxValue != nil {
                yValueMax = yMaxValue
            } else {
                getYValueMax(yLabels: yValues)
            }
            xLabelWidth = (self.frame.size.width - chartMargin * 2.0) / CGFloat(yValues.count)
        }
    }
    
    
    var yChartLabelWidth: CGFloat = 18.0
    
    var chartMargin: CGFloat = 15.0
    
    var showLabel = true
    
    var showChartBorder = false
    
    var chartBottomLine = CAShapeLayer()
    
    var chartLeftLine = CAShapeLayer()
    
    var barRadius: CGFloat = 0.0
    
    var barWidth: CGFloat!
    
    var labelMarginTop: CGFloat = 0.0
    
    var barBackgroundColor = PNLightGrey
    
    var labelTextColor = UIColor.darkGray
    
    var labelTextFont = UIFont(name: "Avenir-Medium", size: 11.0)
    
    var xLabelSkip = 1
    
    var yLabelSum = 4
    
    // Max value of the chart
    var yMaxValue: CGFloat!
    
    // Min value of the chart
    var yMinValue: CGFloat!
    
    var animationType: AnimationType = .Default
    
    // Initialize Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = PNLightGrey
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func strokeChart() {
        self.viewCleanUpForCollection(arr: labels)
        
        if showLabel {
            // Add X Labels
            var labelAddCount = 0
            for index in 0..<xLabels.count {
                labelAddCount = labelAddCount + 1
                
                if labelAddCount == xLabelSkip {
                    let labeltext = xLabels[index]
                    let label = PNChartLabel(frame: CGRect.zero)
                    label.font = labelTextFont
                    label.textColor = labelTextColor
                    label.textAlignment = .center
                    label.text = labeltext
                    label.sizeToFit()
                    
                    let labelXPosition = (CGFloat(index) * xLabelWidth + chartMargin + xLabelWidth / 2.0)
                    label.center = CGPoint(x: labelXPosition, y: self.frame.size.height - xLabelHeight - chartMargin + label.frame.size.height / 2.0 + labelMarginTop)
                    labelAddCount = 0
                    
                    labels.add(label)
                    self.addSubview(label)
                }
            }
            
            // Add Y Labels
            let yLabelSectionHeight = (self.frame.size.height - chartMargin * 2.0 - xLabelHeight) / CGFloat(yLabelSum)
            for index in 0..<yLabelSum {
                let labelText = String(describing: Int(yValueMax * (CGFloat(yLabelSum - index) / CGFloat(yLabelSum))))
                let label = PNChartLabel(frame: CGRect(x: 0.0, y: yLabelSectionHeight * CGFloat(index) + chartMargin - yLabelHeight / 2.0, width: yChartLabelWidth, height: yLabelHeight))
                label.font = labelTextFont
                label.textColor = labelTextColor
                label.textAlignment = .right
                label.text = labelText
                labels.add(label)
                self.addSubview(label)
            }
        }
        
        self.viewCleanUpForCollection(arr: bars)
        
        // Add bars
        let chartCarvanHeight = self.frame.size.height - chartMargin * 2.0 - xLabelHeight
        var index = 0
        
        for value in yValues {
            let grade = value / yValueMax
            var barXPosition: CGFloat!
            
            if barWidth != nil && barWidth > 0 {
                barXPosition = CGFloat(index) * xLabelWidth + chartMargin + (xLabelWidth / 2.0) - (barWidth / 2.0)
            } else {
                barXPosition = CGFloat(index) * xLabelWidth + chartMargin + xLabelWidth * 0.25
                if showLabel {
                    barWidth = xLabelWidth * 0.5
                } else {
                    barWidth = xLabelWidth * 0.6
                }
            }
            
            let bar = PNBar(frame: CGRect(x: barXPosition, y: self.frame.size.height - chartCarvanHeight - xLabelHeight - chartMargin, width: barWidth, height: chartCarvanHeight))
            bar.barRadius = barRadius
            bar.backgroundColor = barBackgroundColor
            
            if strokeColor != UIColor.black {
                bar.barColor = strokeColor
            } else {
                bar.barColor = self.barColorAtIndex(index: index)
            }
            
            if animationType == .Waterfall {
                bar.startAnimationTime = Double(index) * 0.1
            }
            
            // Height of Bar
            bar.grade = grade
            
            // For Click Index
            bar.tag = index
            
            bars.add(bar)
            self.addSubview(bar)
            
            index = index + 1
        }
        
        // Add Chart Border Lines
        if showChartBorder {
            chartBottomLine = CAShapeLayer()
            chartBottomLine.lineCap = kCALineCapButt
            chartBottomLine.fillColor = UIColor.white.cgColor
            chartBottomLine.lineWidth = 1.0
            chartBottomLine.strokeEnd = 0.0
            
            let progressLine = UIBezierPath()
            progressLine.move(to: CGPoint(x: chartMargin, y: self.frame.size.height - xLabelHeight - chartMargin))
            progressLine.addLine(to: CGPoint(x: self.frame.size.width - chartMargin, y: self.frame.size.height - xLabelHeight - chartMargin))
            progressLine.lineWidth = 1.0
            progressLine.lineCapStyle = .square
            chartBottomLine.path = progressLine.cgPath
            
            let path = CABasicAnimation(keyPath: "strokeEnd")
            path.duration = 0.5
            path.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            path.fromValue = 0.0
            path.toValue = 1.0
            chartBottomLine.add(path, forKey: "strokeEndAnimation")
            chartBottomLine.strokeEnd = 1.0
            
            self.layer.addSublayer(chartBottomLine)
            
            // Add Left Chart Line
            chartLeftLine = CAShapeLayer()
            chartLeftLine.lineCap = kCALineCapButt
            chartLeftLine.fillColor = UIColor.white.cgColor
            chartLeftLine.lineWidth = 1.0
            chartLeftLine.strokeEnd = 0.0
            
            let progressLeftLine = UIBezierPath()
            progressLeftLine.move(to: CGPoint(x: chartMargin, y: self.frame.size.height - xLabelHeight - chartMargin))
            progressLeftLine.addLine(to: CGPoint(x: chartMargin, y: chartMargin))
            
            progressLeftLine.lineWidth = 1.0
            progressLeftLine.lineCapStyle = .square
            chartLeftLine.path = progressLeftLine.cgPath
            
            chartLeftLine.strokeColor = PNLightGrey.cgColor
            
            let pathLeft = CABasicAnimation(keyPath: "strokeEnd")
            pathLeft.duration = 0.5
            pathLeft.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            pathLeft.fromValue = 0.0
            pathLeft.toValue = 1.0
            
            chartLeftLine.add(pathLeft, forKey: "strokeEndAnimation")
            chartLeftLine.strokeEnd = 1.0
            
            self.layer.addSublayer(chartLeftLine)
        }
    }
    
}

extension PNBarChart {
    enum AnimationType {
        case Default
        case Waterfall
    }
    
    func getYValueMax(yLabels: [CGFloat]) {
        let max = yLabels.max()
        if max == 0 {
            yValueMax = yMinValue
        } else {
            yValueMax = max
        }
    }
    
    func viewCleanUpForCollection(arr: NSMutableArray) {
        if arr.count > 0 {
            for object in arr {
                let view = object as! UIView
                view.removeFromSuperview()
            }
            arr.removeAllObjects()
        }
    }
    
    func barColorAtIndex(index: Int) -> UIColor {
        if strokeColors.count == yValues.count {
            return strokeColors[index] as! UIColor 
        } else {
            return strokeColor
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchPoint(touches, with: event)
        super.touchesBegan(touches, with: event)
    }
    
    func touchPoint(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchPoint = touch?.location(in: self)
        let subview = hitTest(touchPoint!, with: nil)
        
        if let barView = subview as? PNBar {
            userClickedOnBarChartIndex(barIndex: barView.tag)
        }
    }
    
    func userClickedOnBarChartIndex(barIndex: Int) {
        print("Click on bar \(barIndex)")
    }
}
