//
//  PNLineChart.swift
//  PNChart-Swift
//
//  Created by kevinzhow on 6/4/14.
//  Copyright (c) 2014 Catch Inc. All rights reserved.
//

import UIKit
import QuartzCore


class PNLineChart: UIView{
    
    var xLabels: NSArray = []{
        didSet{
            
            if self.showLabel {
                
                self.xLabelWidth = self.chartCavanWidth! / CGFloat(self.xLabels.count)
                
                for var index = 0;index < self.xLabels.count; ++index {
                    var labelText = self.xLabels[index] as NSString
                    var labelX = 2.0 * self.chartMargin +  ( CGFloat(index) * self.xLabelWidth) - (self.xLabelWidth / 2.0)
                    var label:PNChartLabel = PNChartLabel(frame: CGRect(x:  labelX, y: self.chartMargin + self.chartCavanHeight!, width: self.xLabelWidth, height: self.chartMargin))
                    label.textAlignment = NSTextAlignment.Center
                    label.text = labelText
                    self.addSubview(label)
                }
            }else {
                self.xLabelWidth = self.frame.size.width / CGFloat(self.xLabels.count)
            }
        }
    }
    
    var yLabels: NSArray = []{
        didSet{

            self.yLabelNum = CGFloat(self.yLabels.count)
            var yStep:CGFloat = (self.yValueMax - self.yValueMin) / CGFloat(self.yLabelNum)
            var yStepHeight:CGFloat  = self.chartCavanHeight! / CGFloat(self.yLabelNum)
            
            var index:CGFloat = 0
            var num:CGFloat  = self.yLabelNum + 1
            
            for count : AnyObject in self.yLabels
            {
                
                
                var labelY = self.chartCavanHeight - (index * yStepHeight)
                var label: PNChartLabel = PNChartLabel(frame: CGRect(x: 0.0, y: CGFloat(labelY), width: CGFloat(self.chartMargin + 5.0), height: CGFloat(self.yLabelHeight) ) )
                label.textAlignment = NSTextAlignment.Right
                label.text = NSString(format:self.yLabelFormat, self.yValueMin + (yStep * index))
                ++index
                self.addSubview(label)
            }
        }
    }
    
    /**
    * Array of `LineChartData` objects, one for each line.
    */
    
    var chartData: NSArray = []{
        didSet{
            var yLabelsArray:NSMutableArray = NSMutableArray(capacity: self.chartData.count)
            var yMax:CGFloat = 0.0
            var yMin:CGFloat = MAXFLOAT
            var yValue:CGFloat!
            
            // remove all shape layers before adding new ones
            for layer : AnyObject in self.chartLineArray{
                (layer as CALayer).removeFromSuperlayer()
            }
            for layer : AnyObject in self.chartPointArray {
                (layer as CALayer).removeFromSuperlayer()
            }
            
            self.chartLineArray = NSMutableArray(capacity: self.chartData.count)
            self.chartPointArray = NSMutableArray(capacity: self.chartData.count)
            
            // set for point stoken
            var circle_stroke_width:CGFloat = 2.0
            var line_width:CGFloat = 3.0
            
            for chart : AnyObject in self.chartData{
                // create as many chart line layers as there are data-lines
                var chartObj = chart as PNLineChartData
                var chartLine:CAShapeLayer = CAShapeLayer()
                chartLine.lineCap       = kCALineCapButt
                chartLine.lineJoin      = kCALineJoinMiter
                chartLine.fillColor     = UIColor.whiteColor().CGColor
                chartLine.lineWidth     = line_width
                chartLine.strokeEnd     = 0.0
                self.layer.addSublayer(chartLine)
                self.chartLineArray.addObject(chartLine)
                
                // create point
                var pointLayer:CAShapeLayer = CAShapeLayer()
                pointLayer.strokeColor   = chartObj.color.CGColor
                pointLayer.lineCap       = kCALineCapRound
                pointLayer.lineJoin      = kCALineJoinBevel
                pointLayer.fillColor     = nil
                pointLayer.lineWidth     = circle_stroke_width
                self.layer.addSublayer(pointLayer)
                self.chartPointArray.addObject(pointLayer)
                
                for var i = 0; i < chartObj.itemCount; ++i{
                    yValue = CGFloat(chartObj.getData(i).y)
                    yLabelsArray.addObject(NSString(format: "%2f", yValue))
                    yMax = fmaxf(yMax, yValue)
                    yMin = fminf(yMin, yValue)
                }
            }
            
            // Min value for Y label
            if yMax < 5 {
                yMax = 5.0
            }
            
            if yMin < 0{
                yMin = 0.0
            }
            
            self.yValueMin = yMin;
            self.yValueMax = yMax;

            
            if self.showLabel {
                println("show y label")
                self.yLabels = yLabelsArray as NSArray
            }
            
            self.setNeedsDisplay()
            
        }
    }
    
    var pathPoints: NSMutableArray = []
    
    //For X
    
    var xLabelWidth:CGFloat = 0.0
    
    //For Y
    
    var yValueMax:CGFloat = 10.0
    
    var yValueMin:CGFloat = 1.0
    
    var yLabelNum:CGFloat = 0.0
    
    var yLabelHeight:CGFloat = 12.0
    
    //For Chart
    
    var chartCavanHeight:CGFloat!
    
    var chartCavanWidth:CGFloat!
    
    var chartMargin:CGFloat = 25.0
    
    var showLabel: Bool = true
    
    var showCoordinateAxis: Bool = true
    
    // For Axis
    
    var axisColor:UIColor = PNGrey
    
    var axisWidth:CGFloat = 1.0
    
    var xUnit: NSString!
    
    var yUnit: NSString!
    
    /**
    *  String formatter for float values in y labels. If not set, defaults to @"%1.f"
    */
    
    var yLabelFormat:NSString = "%1.f"
    
    var chartLineArray: NSMutableArray = []  // Array[CAShapeLayer]
    var chartPointArray: NSMutableArray = [] // Array[CAShapeLayer] save the point layer
    
    var chartPaths: NSMutableArray = []     // Array of line path, one for each line.
    var pointPaths: NSMutableArray = []       // Array of point path, one for each line
    
    var delegate:PNChartDelegate?
    

    func setDefaultValues() {
        self.backgroundColor = UIColor.whiteColor()
        self.clipsToBounds = true
        self.chartLineArray = NSMutableArray()
        self.showLabel = false
        self.pathPoints = NSMutableArray()
        self.userInteractionEnabled = true
        
        self.chartCavanWidth = self.frame.size.width - (self.chartMargin * 2.0)
        self.chartCavanHeight = self.frame.size.height - (self.chartMargin * 2.0)
    }
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {

        self.touchPoint(touches, withEvent: event)
        self.touchKeyPoint(touches, withEvent: event)
    }
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {

        self.touchPoint(touches, withEvent: event)
        self.touchKeyPoint(touches, withEvent: event)
    }
    
    func touchPoint(touches: NSSet!, withEvent event: UIEvent!){
        var touch:UITouch = touches.anyObject() as UITouch
        var touchPoint = touch.locationInView(self)
        
        for linePoints:AnyObject in self.pathPoints {
            var linePointsArray = linePoints as NSArray
            
            for var i:NSInteger = 0; i < (linePointsArray.count - 1); i += 1{

                var p1:CGPoint = (linePointsArray[i] as PNValue).point
                var p2:CGPoint = (linePointsArray[i+1] as PNValue).point
                

                
                // Closest distance from point to line
                var distance:CGFloat = fabsf(((p2.x - p1.x) * (touchPoint.y - p1.y)) - ((p1.x - touchPoint.x) * (p1.y - p2.y)))
                distance =  distance /  hypotf( p2.x - p1.x,  p1.y - p2.y )
                

                if distance <= 5.0 {
                    // Conform to delegate parameters, figure out what bezier path this CGPoint belongs to.

                    for path : AnyObject in self.chartPaths {
                        
                        var pointContainsPath:Bool = CGPathContainsPoint((path as UIBezierPath).CGPath, nil, p1, false)

                        if pointContainsPath {

                            self.delegate?.userClickedOnLinePoint(touchPoint , lineIndex: self.chartPaths.indexOfObject(path))
                        }
                    }
                }

                
            }
            
            
        }
    }
    
    
    func touchKeyPoint(touches: NSSet!, withEvent event: UIEvent!){
        var touch:UITouch = touches.anyObject() as UITouch
        var touchPoint = touch.locationInView(self)
        
        for linePoints: AnyObject in self.pathPoints {
            var linePointsArray: NSArray = self.pathPoints as NSArray
            
            for var i:NSInteger = 0; i < (linePointsArray.count - 1); i += 1{
                var p1:CGPoint = (linePointsArray[i] as PNValue).point
                var p2:CGPoint = (linePointsArray[i+1] as PNValue).point
                
                var distanceToP1: CGFloat = fabsf( CGFloat( hypotf( touchPoint.x - p1.x , touchPoint.y - p1.y ) ))
                var distanceToP2: CGFloat = hypotf( touchPoint.x - p2.x, touchPoint.y - p2.y)
                
                var distance: CGFloat = fminf(distanceToP1, distanceToP2)

                if distance <= 10.0 {

                    self.delegate?.userClickedOnLineKeyPoint(touchPoint , lineIndex: self.pathPoints.indexOfObject(linePoints) ,keyPointIndex:(distance == distanceToP2 ? i + 1 : i) )
                }
            }
        }

    }
    
    /**
    * This method will call and troke the line in animation
    */
    
    func strokeChart(){
        self.chartPaths = NSMutableArray()
        self.pointPaths = NSMutableArray()
            
            //Draw each line
        for var lineIndex = 0; lineIndex < self.chartData.count; lineIndex++ {
            var chartData:PNLineChartData = self.chartData[lineIndex] as PNLineChartData
            var chartLine:CAShapeLayer = self.chartLineArray[lineIndex] as CAShapeLayer
            var pointLayer:CAShapeLayer = self.chartPointArray[lineIndex] as CAShapeLayer
                
            var yValue:CGFloat?
            var innerGrade:CGFloat?
                
            UIGraphicsBeginImageContext(self.frame.size)
                
            var progressline:UIBezierPath = UIBezierPath()
            progressline.lineWidth = chartData.lineWidth
            progressline.lineCapStyle = kCGLineCapRound
            progressline.lineJoinStyle = kCGLineJoinRound
                
            var pointPath:UIBezierPath = UIBezierPath()
            pointPath.lineWidth = chartData.lineWidth
            self.chartPaths.addObject(progressline)
            self.pointPaths.addObject(pointPath)
                
            if !self.showLabel {
                self.chartCavanHeight = self.frame.size.height - 2 * self.yLabelHeight
                self.chartCavanWidth = self.frame.size.width
                self.chartMargin = 0.0
                self.xLabelWidth = (self.chartCavanWidth! / CGFloat(self.xLabels.count - 1))
            }
            
            var linePointsArray:NSMutableArray = NSMutableArray()
                
            var last_x:CGFloat = 0.0
            var last_y:CGFloat = 0.0
            var inflexionWidth:CGFloat = chartData.inflexionPointWidth
                
            for var i:Int = 0; i < chartData.itemCount; i++ {
                yValue = CGFloat(chartData.getData(i).y)
                    
                innerGrade = (yValue! - self.yValueMin) / (self.yValueMax - self.yValueMin)
                    
                var x:CGFloat = 2.0 * self.chartMargin +  (CGFloat(i) * self.xLabelWidth)
                var y:CGFloat = self.chartCavanHeight! - (innerGrade! * self.chartCavanHeight!) + (self.yLabelHeight / 2.0)
                    
                // cycle style point
                if chartData.inflexionPointStyle == PNLineChartData.PNLineChartPointStyle.PNLineChartPointStyleCycle{
                    
                    var circleRect:CGRect = CGRectMake(x-inflexionWidth/2.0, y-inflexionWidth/2.0, inflexionWidth,inflexionWidth)
                    var circleCenter:CGPoint = CGPointMake(circleRect.origin.x + (circleRect.size.width / 2.0), circleRect.origin.y + (circleRect.size.height / 2.0))
                    pointPath.moveToPoint(CGPointMake(circleCenter.x + (inflexionWidth/2), circleCenter.y))

                    pointPath.addArcWithCenter(circleCenter, radius: CGFloat(inflexionWidth/2.0), startAngle: 0.0, endAngle:CGFloat(2.0*M_PI), clockwise: true)
                    

                    if i != 0 {
                        
                        // calculate the point for line
                        var distance:CGFloat = sqrtf( powf( x-last_x, 2.0) + powf( y-last_y,2.0) )
                        var last_x1:CGFloat = last_x + (inflexionWidth/2) / distance * (x-last_x)
                        var last_y1:CGFloat = last_y + (inflexionWidth/2) / distance * (y-last_y)
                        var x1:CGFloat = x - (inflexionWidth/2) / distance * (x-last_x)
                        var y1:CGFloat = y - (inflexionWidth/2) / distance * (y-last_y)
                        progressline.moveToPoint(CGPointMake(last_x1, last_y1))
                        progressline.addLineToPoint(CGPointMake(x1, y1))
                    }
                    last_x = x
                    last_y = y
                }
                // Square style point
                else if chartData.inflexionPointStyle == PNLineChartData.PNLineChartPointStyle.PNLineChartPointStyleSquare{
                    
                    var squareRect:CGRect = CGRectMake(x-inflexionWidth/2, y-inflexionWidth/2, inflexionWidth,inflexionWidth)
                    var squareCenter:CGPoint = CGPointMake(squareRect.origin.x + (squareRect.size.width / 2), squareRect.origin.y + (squareRect.size.height / 2))
                    
                    pointPath.moveToPoint(CGPointMake(squareCenter.x - (inflexionWidth/2), squareCenter.y - (inflexionWidth/2)))
                    pointPath.addLineToPoint(CGPointMake(squareCenter.x + (inflexionWidth/2), squareCenter.y - (inflexionWidth/2)))
                    pointPath.addLineToPoint(CGPointMake(squareCenter.x + (inflexionWidth/2), squareCenter.y + (inflexionWidth/2)))
                    pointPath.addLineToPoint(CGPointMake(squareCenter.x - (inflexionWidth/2), squareCenter.y + (inflexionWidth/2)))
                    pointPath.closePath()
                    
                    if i != 0{
                        
                        // calculate the point for line
                        var distance:CGFloat = sqrtf( powf(x-last_x, 2) + powf(y-last_y,2) )
                        var last_x1:CGFloat = last_x + (inflexionWidth/2)
                        var last_y1:CGFloat = last_y + (inflexionWidth/2) / distance * (y-last_y)
                        var x1:CGFloat = x - (inflexionWidth/2)
                        var y1:CGFloat = y - (inflexionWidth/2) / distance * (y-last_y)
                        
                        progressline.moveToPoint(CGPointMake(last_x1, last_y1))
                        progressline.addLineToPoint(CGPointMake(x1, y1))
                    }
                    
                    last_x = x
                    last_y = y
                }
                // Triangle style point
                else if (chartData.inflexionPointStyle == PNLineChartData.PNLineChartPointStyle.PNLineChartPointStyleTriangle) {
                    
                    if i != 0 {
                        progressline.addLineToPoint(CGPointMake(x, y))
                    }
                    
                    progressline.moveToPoint(CGPointMake(x, y))
                } else {
                    
                    if i != 0 {
                        progressline.addLineToPoint(CGPointMake(x, y))
                    }
                    
                    progressline.moveToPoint(CGPointMake(x, y))
                }
                
                
                linePointsArray.addObject(PNValue(point: CGPointMake(x, y)))
                
                
            }
            
            self.pathPoints.addObject(linePointsArray)
            
            // setup the color of the chart line
            if chartData.color != nil {
                chartLine.strokeColor = chartData.color.CGColor
                pointLayer.strokeColor = chartData.color.CGColor
            }
            else {
                chartLine.strokeColor = PNGreenColor.CGColor
                pointLayer.strokeColor = PNGreenColor.CGColor
            }
            
            progressline.stroke()
            
            chartLine.path = progressline.CGPath
            pointLayer.path = pointPath.CGPath
            
            
            CATransaction.begin()
            var pathAnimation:CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
            pathAnimation.duration = 1.0
            pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            pathAnimation.fromValue = 0.0
            pathAnimation.toValue   = 1.0
            
            chartLine.addAnimation(pathAnimation, forKey:"strokeEndAnimation")
            chartLine.strokeEnd = 1.0
            
            // if you want cancel the point animation, conment this code, the point will show immediately
            if chartData.inflexionPointStyle != PNLineChartData.PNLineChartPointStyle.PNLineChartPointStyleNone {
                pointLayer.addAnimation(pathAnimation, forKey:"strokeEndAnimation")
            }
            
            CATransaction.commit()
            
            UIGraphicsEndImageContext()
        }
        
    }
    
    override func drawRect(rect: CGRect)
    {
        if self.showCoordinateAxis {
            
            var yAsixOffset:CGFloat = 10.0
            
            var ctx:CGContextRef = UIGraphicsGetCurrentContext()
            UIGraphicsPushContext(ctx)
            CGContextSetLineWidth(ctx, self.axisWidth)
            CGContextSetStrokeColorWithColor(ctx, self.axisColor.CGColor)
            
            var xAxisWidth:CGFloat = CGRectGetWidth(rect) - self.chartMargin/2.0
            var yAxisHeight:CGFloat = self.chartMargin + self.chartCavanHeight!
            
            // draw coordinate axis
            CGContextMoveToPoint(ctx, self.chartMargin + yAsixOffset, 0)
            CGContextAddLineToPoint(ctx, self.chartMargin + yAsixOffset, yAxisHeight)
            CGContextAddLineToPoint(ctx, xAxisWidth, yAxisHeight)
            CGContextStrokePath(ctx)
            
            // draw y axis arrow
            CGContextMoveToPoint(ctx, self.chartMargin + yAsixOffset - 3, 6)
            CGContextAddLineToPoint(ctx, self.chartMargin + yAsixOffset, 0)
            CGContextAddLineToPoint(ctx, self.chartMargin + yAsixOffset + 3, 6)
            CGContextStrokePath(ctx);
            
            // draw x axis arrow
            CGContextMoveToPoint(ctx, xAxisWidth - 6, yAxisHeight - 3)
            CGContextAddLineToPoint(ctx, xAxisWidth, yAxisHeight)
            CGContextAddLineToPoint(ctx, xAxisWidth - 6, yAxisHeight + 3);
            CGContextStrokePath(ctx)
            
            if self.showLabel{
                
                // draw x axis separator
                var point:CGPoint!
                for var i:Int = 0; i < self.xLabels.count; ++i {
                    point = CGPointMake(2 * self.chartMargin +  ( CGFloat(i) * self.xLabelWidth), self.chartMargin + self.chartCavanHeight!)
                    CGContextMoveToPoint(ctx, point.x, point.y - 2)
                    CGContextAddLineToPoint(ctx, point.x, point.y)
                    CGContextStrokePath(ctx)
                }
                
                // draw y axis separator
                var yStepHeight:CGFloat = self.chartCavanHeight! / CGFloat(self.yLabelNum)
                for var i:Int = 0; i < self.xLabels.count; ++i {
                    point = CGPointMake(self.chartMargin + yAsixOffset, (self.chartCavanHeight! - CGFloat(i) * yStepHeight + self.yLabelHeight/2.0
                        ))
                    CGContextMoveToPoint(ctx, point.x, point.y)
                    CGContextAddLineToPoint(ctx, point.x + 2, point.y)
                    CGContextStrokePath(ctx)
                }
            }
            
            var font:UIFont = UIFont.systemFontOfSize(11)
            // draw y unit
            if self.yUnit != nil{
                var height:CGFloat = self.heightOfString(self.yUnit, width: 30.0, font: font)
                var drawRect:CGRect = CGRectMake(self.chartMargin + 10 + 5, 0, 30.0, height)
                self.drawTextInContext(ctx, text:self.yUnit, rect:drawRect, font:font)
            }
            
            // draw x unit
            if self.xUnit != nil {
                var height:CGFloat = self.heightOfString(self.yUnit, width:30.0, font:font)
                var drawRect:CGRect = CGRectMake(CGRectGetWidth(rect) - self.chartMargin + 5, self.chartMargin + self.chartCavanHeight! - height/2, 25.0, height)
                self.drawTextInContext(ctx, text:self.yUnit, rect:drawRect, font:font)
            }
        }
        
        super.drawRect(rect)
    }
    
    func heightOfString(text: NSString!, width: CGFloat, font: UIFont) -> CGFloat{
        var ch:CGFloat!
        var size:CGSize = CGSizeMake(width, MAXFLOAT)

        var tdic:NSDictionary = NSDictionary(objects: [font, NSFontAttributeName], forKeys: nil)
        size = text.boundingRectWithSize(size, options: NSStringDrawingOptions.UsesFontLeading , attributes: tdic, context: nil).size
        ch = size.height
        return ch

    }
    
    func drawTextInContext(ctx: CGContextRef, text: NSString!, rect: CGRect, font:UIFont){
        var priceParagraphStyle:NSMutableParagraphStyle = NSParagraphStyle.defaultParagraphStyle() as NSMutableParagraphStyle
        priceParagraphStyle.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        priceParagraphStyle.alignment = NSTextAlignment.Left
        
        text.drawInRect(rect, withAttributes: [ NSParagraphStyleAttributeName:priceParagraphStyle, NSFontAttributeName:font] )
    }
    
    
    init(frame: CGRect){
        super.init(frame: frame)
        self.setDefaultValues()
    }
    
}
