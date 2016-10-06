//
//  PNBarChart.swift
//  PNChart-Swift
//
//  Created by kevinzhow on 6/6/14.
//  Copyright (c) 2014 Catch Inc. All rights reserved.
//

import UIKit
import QuartzCore

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


public enum AnimationType {
    case `default`
    case waterfall
}

open class PNBarChart: UIView {
    
    // MARK: Variables
    
    open  var xLabels: NSArray = [] {
        
        didSet{
            if showLabel {
                xLabelWidth = (self.frame.size.width - chartMargin * 2.0) / CGFloat(self.xLabels.count)
            }
        }
    }
    var labels: NSMutableArray = []
    var yLabels: NSArray = []
    open var yValues: NSArray = [] {
        didSet{
            if (yMaxValue != nil) {
                yValueMax = yMaxValue
            }else{
                self.getYValueMax(yValues)
            }
            
            xLabelWidth = (self.frame.size.width - chartMargin * 2.0) / CGFloat(yValues.count)
        }
    }
    
    var bars: NSMutableArray = []
    open var xLabelWidth:CGFloat!
    open var yValueMax: CGFloat!
    open var strokeColor: UIColor = PNGreenColor
    open var strokeColors: NSArray = []
    open var xLabelHeight:CGFloat = 11.0
    open var yLabelHeight:CGFloat = 20.0
    
    /*
    chartMargin changes chart margin
    */
    open var yChartLabelWidth:CGFloat = 18.0
    
    /*
    yLabelFormatter will format the ylabel text
    */
    var yLabelFormatter = ({(index: CGFloat) -> NSString in
        return ""
    })
    
    /*
    chartMargin changes chart margin
    */
    open var chartMargin:CGFloat = 15.0
    
    /*
    showLabel if the Labels should be deplay
    */
    
    open var showLabel = true
    
    /*
    showChartBorder if the chart border Line should be deplay
    */
    
    open var showChartBorder = false
    
    /*
    chartBottomLine the Line at the chart bottom
    */
    
    open var chartBottomLine:CAShapeLayer = CAShapeLayer()
    
    /*
    chartLeftLine the Line at the chart left
    */
    
    open var chartLeftLine:CAShapeLayer = CAShapeLayer()
    
    /*
    barRadius changes the bar corner radius
    */
    open var barRadius:CGFloat = 0.0
    
    /*
    barWidth changes the width of the bar
    */
    open var barWidth:CGFloat!
    
    /*
    labelMarginTop changes the width of the bar
    */
    open var labelMarginTop: CGFloat = 0
    
    /*
    barBackgroundColor changes the bar background color
    */
    open var barBackgroundColor:UIColor = UIColor.gray
    
    /*
    labelTextColor changes the bar label text color
    */
    open var labelTextColor: UIColor = PNGreyColor
    
    /*
    labelFont changes the bar label font
    */
    open var labelFont: UIFont = UIFont.systemFont(ofSize: 11.0)
    
    /*
    xLabelSkip define the label skip number
    */
    open var xLabelSkip:Int = 1
    
    /*
    yLabelSum define the label skip number
    */
    open var yLabelSum:Int = 4
    
    /*
    yMaxValue define the max value of the chart
    */
    open var yMaxValue:CGFloat!
    
    /*
    yMinValue define the min value of the chart
    */
    open var yMinValue:CGFloat!
    
    /*
    animationType defines the type of animation for the bars
    Default (All bars at once) / Waterfall (bars in sequence)
    */
    open var animationType : AnimationType = .default
    
    open var delegate:PNChartDelegate!
    
    /**
    * This method will call and stroke the line in animation
    */
    
    // MARK: Functions
    
    open  func strokeChart() {
        self.viewCleanupForCollection(labels)
        
        if showLabel{
            //Add x labels
            var labelAddCount:Int = 0
            for index:Int in 0 ..< xLabels.count += 1 {
                labelAddCount += 1
                
                if labelAddCount == xLabelSkip {
                    let labelText:NSString = xLabels[index] as! NSString
                    let label:PNChartLabel = PNChartLabel(frame: CGRect.zero)
                    label.font = labelFont
                    label.textColor = labelTextColor
                    label.textAlignment = NSTextAlignment.center
                    label.text = labelText as String
                    label.sizeToFit()
                    let labelXPosition:CGFloat  = ( CGFloat(index) *  xLabelWidth + chartMargin + xLabelWidth / 2.0 )
                    
                    label.center = CGPoint(x: labelXPosition,
                        y: self.frame.size.height - xLabelHeight - chartMargin + label.frame.size.height / 2.0 + labelMarginTop)
                    labelAddCount = 0
                    
                    labels.add(label)
                    self.addSubview(label)
                }
            }
            
            //Add y labels
            
            let yLabelSectionHeight:CGFloat = (self.frame.size.height - chartMargin * 2.0 - xLabelHeight) / CGFloat(yLabelSum)
            
            for index:Int in 0 ..< yLabelSum += 1 {
                let labelText:NSString = yLabelFormatter((yValueMax * ( CGFloat(yLabelSum - index) / CGFloat(yLabelSum) ) ))
                    
                let label:PNChartLabel = PNChartLabel(frame: CGRect(x: 0,y: yLabelSectionHeight * CGFloat(index) + chartMargin - yLabelHeight/2.0, width: yChartLabelWidth, height: yLabelHeight))
                
                label.font = labelFont
                label.textColor = labelTextColor
                label.textAlignment = NSTextAlignment.right
                label.text = labelText as String
                
                labels.add(label)
                self.addSubview(label)
            }
        }
        
        self.viewCleanupForCollection(bars)
        //Add bars
        let chartCavanHeight:CGFloat = frame.size.height - chartMargin * 2 - xLabelHeight
        var index:Int = 0
        
        for valueObj: Any in yValues{
            let valueString = valueObj as! NSNumber
            let value:CGFloat = CGFloat(valueString.floatValue)
            
            let grade = value / yValueMax
            
            var bar:PNBar!
            var barXPosition:CGFloat!
            
            if barWidth > 0 {
                
                barXPosition = CGFloat(index) *  xLabelWidth + chartMargin + (xLabelWidth / 2.0) - (barWidth / 2.0)
            }else{
                barXPosition = CGFloat(index) *  xLabelWidth + chartMargin + xLabelWidth * 0.25
                if showLabel {
                    barWidth = xLabelWidth * 0.5
                    
                }
                else {
                    barWidth = xLabelWidth * 0.6
                    
                }
            }
            
            bar = PNBar(frame: CGRect(x: barXPosition, //Bar X position
                y: frame.size.height - chartCavanHeight - xLabelHeight - chartMargin, //Bar Y position
                width: barWidth, // Bar witdh
                height: chartCavanHeight)) //Bar height
            
            //Change Bar Radius
            bar.barRadius = barRadius
            
            //Change Bar Background color
            bar.backgroundColor = barBackgroundColor
            
            //Bar StrokColor First
            if strokeColor != UIColor.black {
                bar.barColor = strokeColor
            }else{
                bar.barColor = self.barColorAtIndex(index)
            }
            
            if(self.animationType ==  .waterfall)
            {
                let indexDouble : Double = Double(index)
                
                // Time before each bar starts animating
                let barStartTime = indexDouble-(0.9*indexDouble)
                
                bar.startAnimationTime = barStartTime
                
            }
            
            //Height Of Bar
            bar.grade = grade
            
            //For Click Index
            bar.tag = index
            
            bars.add(bar)
            addSubview(bar)
            
            index += 1
        }
        
        //Add chart border lines
        
        if showChartBorder{
            chartBottomLine = CAShapeLayer()
            chartBottomLine.lineCap      = kCALineCapButt
            chartBottomLine.fillColor    = UIColor.white.cgColor
            chartBottomLine.lineWidth    = 1.0
            chartBottomLine.strokeEnd    = 0.0
            
            let progressline:UIBezierPath = UIBezierPath()
            
            progressline.move(to: CGPoint(x: chartMargin, y: frame.size.height - xLabelHeight - chartMargin))
            progressline.addLine(to: CGPoint(x: frame.size.width - chartMargin,  y: frame.size.height - xLabelHeight - chartMargin))
            
            progressline.lineWidth = 1.0
            progressline.lineCapStyle = CGLineCap.square
            chartBottomLine.path = progressline.cgPath
            
            
            chartBottomLine.strokeColor = PNLightGreyColor.cgColor;
            
            
            let pathAnimation:CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
            pathAnimation.duration = 0.5
            pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            pathAnimation.fromValue = 0.0
            pathAnimation.toValue = 1.0
            chartBottomLine.add(pathAnimation, forKey:"strokeEndAnimation")
            chartBottomLine.strokeEnd = 1.0;
            
            layer.addSublayer(chartBottomLine)
            
            //Add left Chart Line
            
            chartLeftLine = CAShapeLayer()
            chartLeftLine.lineCap      = kCALineCapButt
            chartLeftLine.fillColor    = UIColor.white.cgColor
            chartLeftLine.lineWidth    = 1.0
            chartLeftLine.strokeEnd    = 0.0
            
            let progressLeftline:UIBezierPath = UIBezierPath()
            
            progressLeftline.move(to: CGPoint(x: chartMargin, y: frame.size.height - xLabelHeight - chartMargin))
            progressLeftline.addLine(to: CGPoint(x: chartMargin,  y: chartMargin))
            
            progressLeftline.lineWidth = 1.0
            progressLeftline.lineCapStyle = CGLineCap.square
            chartLeftLine.path = progressLeftline.cgPath
            
            
            chartLeftLine.strokeColor = PNLightGreyColor.cgColor
            
            
            let pathLeftAnimation: CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
            pathLeftAnimation.duration = 0.5
            pathLeftAnimation.timingFunction =  CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            pathLeftAnimation.fromValue = 0.0
            pathLeftAnimation.toValue = 1.0
            chartLeftLine.add(pathAnimation, forKey:"strokeEndAnimation")
            
            chartLeftLine.strokeEnd = 1.0
            
            layer.addSublayer(chartLeftLine)
        }
        
    }
    
    func barColorAtIndex(_ index:Int) -> UIColor
    {
        if (self.strokeColors.count == self.yValues.count) {
            return self.strokeColors[index] as! UIColor
        }
        else {
            return self.strokeColor as UIColor
        }
    }
    
    
    func viewCleanupForCollection( _ array:NSMutableArray )
    {
        if array.count > 0 {
            for object:Any in array{
                let view = object as! UIView
                view.removeFromSuperview()
            }
            
            array.removeAllObjects()
        }
    }
    
    func getYValueMax(_ yLabels:NSArray) {
        let max:CGFloat = CGFloat(yLabels.value(forKeyPath: "@max.floatValue") as! Float)
        
        
        if max == 0 {
            yValueMax = yMinValue
        }else{
            yValueMax = max
        }
        
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchPoint(touches, withEvent: event)
        super.touchesBegan(touches, with: event)
    }
    
    
    func touchPoint(_ touches: Set<UITouch>, withEvent event: UIEvent!){
        let touch:UITouch = touches.first!
        let touchPoint = touch.location(in: self)
        let subview = hitTest(touchPoint, with: nil)
        
        if let barView = subview as? PNBar {
            self.delegate?.userClickedOnBarChartIndex(barView.tag)
        }
    }
    
    // MARK: Init
    
    override public init(frame: CGRect)
    {
        super.init(frame: frame)
        barBackgroundColor = PNLightGreyColor
        clipsToBounds = true
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}
