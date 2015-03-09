//
//  PNLineChart.swift
//  PNChart-Swift
//
//  Created by kevinzhow on 6/4/14.
//  Copyright (c) 2014 Catch Inc. All rights reserved.
//

import UIKit
import QuartzCore


public class PNLineChart: UIView{
    
    public var xLabels: NSArray = []{
        didSet{
            
            if showLabel {
                
                xLabelWidth = chartCavanWidth! / CGFloat(xLabels.count)
                
                for var index = 0;index < xLabels.count; ++index {
                    var labelText = xLabels[index] as! NSString
                    var labelX = 2.0 * chartMargin +  ( CGFloat(index) * xLabelWidth) - (xLabelWidth / 2.0)
                    var label:PNChartLabel = PNChartLabel(frame: CGRect(x:  labelX, y: chartMargin + chartCavanHeight!, width: xLabelWidth, height: chartMargin))
                    label.textAlignment = NSTextAlignment.Center
                    label.text = labelText as String
                    addSubview(label)
                }
            }else {
                xLabelWidth = frame.size.width / CGFloat(xLabels.count)
            }
        }
    }
    
    public var yLabels: NSArray = []{
        didSet{

            yLabelNum = CGFloat(yLabels.count)
            var yStep:CGFloat = (yValueMax - yValueMin) / CGFloat(yLabelNum)
            var yStepHeight:CGFloat  = chartCavanHeight! / CGFloat(yLabelNum)
            
            var index:CGFloat = 0
            var num:CGFloat  = yLabelNum + 1
            
            for count : AnyObject in yLabels
            {
                
                
                var labelY = chartCavanHeight - (index * yStepHeight)
                var label: PNChartLabel = PNChartLabel(frame: CGRect(x: 0.0, y: CGFloat(labelY), width: CGFloat(chartMargin + 5.0), height: CGFloat(yLabelHeight) ) )
                label.textAlignment = NSTextAlignment.Right
                label.text = NSString(format:yLabelFormat, Double(yValueMin + (yStep * index))) as String
                ++index
                addSubview(label)
            }
        }
    }
    
    /**
    * Array of `LineChartData` objects, one for each line.
    */
    
    public var chartData: NSArray = []{
        didSet{
            var yLabelsArray:NSMutableArray = NSMutableArray(capacity: chartData.count)
            var yMax:CGFloat = 0.0
            var yMin:CGFloat = CGFloat.max
            var yValue:CGFloat!
            
            // remove all shape layers before adding new ones
            for layer : AnyObject in chartLineArray{
                (layer as! CALayer).removeFromSuperlayer()
            }
            for layer : AnyObject in chartPointArray {
                (layer as! CALayer).removeFromSuperlayer()
            }
            
            chartLineArray = NSMutableArray(capacity: chartData.count)
            chartPointArray = NSMutableArray(capacity: chartData.count)
            
            // set for point stoken
            var circle_stroke_width:CGFloat = 2.0
            var line_width:CGFloat = 3.0
            
            for chart : AnyObject in chartData{
                // create as many chart line layers as there are data-lines
                var chartObj = chart as! PNLineChartData
                var chartLine:CAShapeLayer = CAShapeLayer()
                chartLine.lineCap       = kCALineCapButt
                chartLine.lineJoin      = kCALineJoinMiter
                chartLine.fillColor     = UIColor.whiteColor().CGColor
                chartLine.lineWidth     = line_width
                chartLine.strokeEnd     = 0.0
                layer.addSublayer(chartLine)
                chartLineArray.addObject(chartLine)
                
                // create point
                var pointLayer:CAShapeLayer = CAShapeLayer()
                pointLayer.strokeColor   = chartObj.color.CGColor
                pointLayer.lineCap       = kCALineCapRound
                pointLayer.lineJoin      = kCALineJoinBevel
                pointLayer.fillColor     = nil
                pointLayer.lineWidth     = circle_stroke_width
                layer.addSublayer(pointLayer)
                chartPointArray.addObject(pointLayer)
                
                for var i = 0; i < chartObj.itemCount; ++i{
                    yValue = CGFloat(chartObj.getData(i).y)
                    yLabelsArray.addObject(NSString(format: "%2f", yValue))
                    yMax = fmax(yMax, yValue)
                    yMin = fmin(yMin, yValue)
                }
            }
            
            // Min value for Y label
            if yMax < 5 {
                yMax = 5.0
            }
            
            if yMin < 0{
                yMin = 0.0
            }
            
            yValueMin = yMin;
            yValueMax = yMax;

            
            if showLabel {
                println("show y label")
                yLabels = yLabelsArray as NSArray
            }
            
            setNeedsDisplay()
            
        }
    }
    
    var pathPoints: NSMutableArray = []
    
    //For X
    
    public var xLabelWidth:CGFloat = 0.0
    
    //For Y
    
    public var yValueMax:CGFloat = 10.0
    
    public var yValueMin:CGFloat = 1.0
    
    public var yLabelNum:CGFloat = 0.0
    
    public var yLabelHeight:CGFloat = 12.0
    
    //For Chart
    
    public var chartCavanHeight:CGFloat!
    
    public var chartCavanWidth:CGFloat!
    
    public var chartMargin:CGFloat = 25.0
    
    public var showLabel: Bool = true
    
    public var showCoordinateAxis: Bool = true
    
    // For Axis
    
    public var axisColor:UIColor = PNGreyColor
    
    public var axisWidth:CGFloat = 1.0
    
    public var xUnit: NSString!
    
    public var yUnit: NSString!
    
    /**
    *  String formatter for float values in y labels. If not set, defaults to @"%1.f"
    */
    
    public var yLabelFormat:NSString = "%1.f"
    
    var chartLineArray: NSMutableArray = []  // Array[CAShapeLayer]
    var chartPointArray: NSMutableArray = [] // Array[CAShapeLayer] save the point layer
    
    var chartPaths: NSMutableArray = []     // Array of line path, one for each line.
    var pointPaths: NSMutableArray = []       // Array of point path, one for each line
    
    public var delegate:PNChartDelegate?
    

    // MARK: Functions 
    
    func setDefaultValues() {
        backgroundColor = UIColor.whiteColor()
        clipsToBounds = true
        chartLineArray = NSMutableArray()
        showLabel = false
        pathPoints = NSMutableArray()
        userInteractionEnabled = true
        
        chartCavanWidth = frame.size.width - (chartMargin * 2.0)
        chartCavanHeight = frame.size.height - (chartMargin * 2.0)
    }
    
    public override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {

        touchPoint(touches, withEvent: event)
        touchKeyPoint(touches, withEvent: event)
    }
    
    override public func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {

        touchPoint(touches, withEvent: event)
        touchKeyPoint(touches, withEvent: event)
    }
    
    func touchPoint(touches: NSSet!, withEvent event: UIEvent!){
        var touch:UITouch = touches.anyObject() as! UITouch
        var touchPoint = touch.locationInView(self)
        
        for linePoints:AnyObject in pathPoints {
            var linePointsArray = linePoints as! NSArray
            
            for var i:NSInteger = 0; i < (linePointsArray.count - 1); i += 1{

                var p1:CGPoint = (linePointsArray[i] as! PNValue).point
                var p2:CGPoint = (linePointsArray[i+1] as! PNValue).point
                

                
                // Closest distance from point to line
                var distance:CGFloat = fabs(((p2.x - p1.x) * (touchPoint.y - p1.y)) - ((p1.x - touchPoint.x) * (p1.y - p2.y)))
                distance =  distance /  hypot( p2.x - p1.x,  p1.y - p2.y )
                

                if distance <= 5.0 {
                    // Conform to delegate parameters, figure out what bezier path this CGPoint belongs to.

                    for path : AnyObject in chartPaths {
                        
                        var pointContainsPath:Bool = CGPathContainsPoint((path as! UIBezierPath).CGPath, nil, p1, false)

                        if pointContainsPath {

                            delegate?.userClickedOnLinePoint(touchPoint , lineIndex: chartPaths.indexOfObject(path))
                        }
                    }
                }

                
            }
            
            
        }
    }
    
    
    func touchKeyPoint(touches: NSSet!, withEvent event: UIEvent!){
        var touch:UITouch = touches.anyObject() as! UITouch
        var touchPoint = touch.locationInView(self)
        
        for linePoints: AnyObject in pathPoints {
            var linePointsArray: NSArray = pathPoints as NSArray
            
            for var i:NSInteger = 0; i < (linePointsArray.count - 1); i += 1{
                var p1:CGPoint = (linePointsArray[i] as! PNValue).point
                var p2:CGPoint = (linePointsArray[i+1] as! PNValue).point
                
                var distanceToP1: CGFloat = fabs( CGFloat( hypot( touchPoint.x - p1.x , touchPoint.y - p1.y ) ))
                var distanceToP2: CGFloat = hypot( touchPoint.x - p2.x, touchPoint.y - p2.y)
                
                var distance: CGFloat = fmin(distanceToP1, distanceToP2)

                if distance <= 10.0 {

                    delegate?.userClickedOnLineKeyPoint(touchPoint , lineIndex: pathPoints.indexOfObject(linePoints) ,keyPointIndex:(distance == distanceToP2 ? i + 1 : i) )
                }
            }
        }

    }
    
    /**
    * This method will call and troke the line in animation
    */
    
    public func strokeChart(){
        chartPaths = NSMutableArray()
        pointPaths = NSMutableArray()
            
            //Draw each line
        for var lineIndex = 0; lineIndex < chartData.count; lineIndex++ {
            var chartData:PNLineChartData = self.chartData[lineIndex] as! PNLineChartData
            var chartLine:CAShapeLayer = chartLineArray[lineIndex] as! CAShapeLayer
            var pointLayer:CAShapeLayer = chartPointArray[lineIndex] as! CAShapeLayer
                
            var yValue:CGFloat?
            var innerGrade:CGFloat?
                
            UIGraphicsBeginImageContext(frame.size)
                
            var progressline:UIBezierPath = UIBezierPath()
            progressline.lineWidth = chartData.lineWidth
            progressline.lineCapStyle = kCGLineCapRound
            progressline.lineJoinStyle = kCGLineJoinRound
                
            var pointPath:UIBezierPath = UIBezierPath()
            pointPath.lineWidth = chartData.lineWidth
            chartPaths.addObject(progressline)
            pointPaths.addObject(pointPath)
                
            if !showLabel {
                chartCavanHeight = frame.size.height - 2 * yLabelHeight
                chartCavanWidth = frame.size.width
                chartMargin = 0.0
                xLabelWidth = (chartCavanWidth! / CGFloat(xLabels.count - 1))
            }
            
            var linePointsArray:NSMutableArray = NSMutableArray()
                
            var last_x:CGFloat = 0.0
            var last_y:CGFloat = 0.0
            var inflexionWidth:CGFloat = chartData.inflexionPointWidth
                
            for var i:Int = 0; i < chartData.itemCount; i++ {
                yValue = CGFloat(chartData.getData(i).y)
                    
                innerGrade = (yValue! - yValueMin) / (yValueMax - yValueMin)
                    
                var x:CGFloat = 2.0 * chartMargin +  (CGFloat(i) * xLabelWidth)
                var y:CGFloat = chartCavanHeight! - (innerGrade! * chartCavanHeight!) + (yLabelHeight / 2.0)
                    
                // cycle style point
                switch chartData.inflexionPointStyle{
                case PNLineChartData.PNLineChartPointStyle.PNLineChartPointStyleCycle:
                    
                    var circleRect:CGRect = CGRectMake(x-inflexionWidth/2.0, y-inflexionWidth/2.0, inflexionWidth,inflexionWidth)
                    var circleCenter:CGPoint = CGPointMake(circleRect.origin.x + (circleRect.size.width / 2.0), circleRect.origin.y + (circleRect.size.height / 2.0))
                    pointPath.moveToPoint(CGPointMake(circleCenter.x + (inflexionWidth/2), circleCenter.y))
                    pointPath.addArcWithCenter(circleCenter, radius: CGFloat(inflexionWidth/2.0), startAngle: 0.0, endAngle:CGFloat(2.0*M_PI), clockwise: true)
                    
                    if i != 0 {
                        
                        // calculate the point for line
                        var distance:CGFloat = sqrt( pow( x-last_x, 2.0) + pow( y-last_y,2.0) )
                        var last_x1:CGFloat = last_x + (inflexionWidth/2) / distance * (x-last_x)
                        var last_y1:CGFloat = last_y + (inflexionWidth/2) / distance * (y-last_y)
                        var x1:CGFloat = x - (inflexionWidth/2) / distance * (x-last_x)
                        var y1:CGFloat = y - (inflexionWidth/2) / distance * (y-last_y)
                        progressline.moveToPoint(CGPointMake(last_x1, last_y1))
                        progressline.addLineToPoint(CGPointMake(x1, y1))
                    }
                    last_x = x
                    last_y = y
                    
                // Square style point
                case PNLineChartData.PNLineChartPointStyle.PNLineChartPointStyleSquare:
                    
                    var squareRect:CGRect = CGRectMake(x-inflexionWidth/2, y-inflexionWidth/2, inflexionWidth,inflexionWidth)
                    var squareCenter:CGPoint = CGPointMake(squareRect.origin.x + (squareRect.size.width / 2), squareRect.origin.y + (squareRect.size.height / 2))
                    
                    pointPath.moveToPoint(CGPointMake(squareCenter.x - (inflexionWidth/2), squareCenter.y - (inflexionWidth/2)))
                    pointPath.addLineToPoint(CGPointMake(squareCenter.x + (inflexionWidth/2), squareCenter.y - (inflexionWidth/2)))
                    pointPath.addLineToPoint(CGPointMake(squareCenter.x + (inflexionWidth/2), squareCenter.y + (inflexionWidth/2)))
                    pointPath.addLineToPoint(CGPointMake(squareCenter.x - (inflexionWidth/2), squareCenter.y + (inflexionWidth/2)))
                    pointPath.closePath()
                    
                    if i != 0{
                        
                        // calculate the point for line
                        var distance:CGFloat = sqrt( pow(x-last_x, 2) + pow(y-last_y,2) )
                        var last_x1:CGFloat = last_x + (inflexionWidth/2)
                        var last_y1:CGFloat = last_y + (inflexionWidth/2) / distance * (y-last_y)
                        var x1:CGFloat = x - (inflexionWidth/2)
                        var y1:CGFloat = y - (inflexionWidth/2) / distance * (y-last_y)
                        
                        progressline.moveToPoint(CGPointMake(last_x1, last_y1))
                        progressline.addLineToPoint(CGPointMake(x1, y1))
                    }
                    
                    last_x = x
                    last_y = y
                    
                // Triangle style point
                case PNLineChartData.PNLineChartPointStyle.PNLineChartPointStyleTriangle:
                    
                    if i != 0 {
                        progressline.addLineToPoint(CGPointMake(x, y))
                    }
                    
                    progressline.moveToPoint(CGPointMake(x, y))
                    
                default:
                    
                    if i != 0 {
                        progressline.addLineToPoint(CGPointMake(x, y))
                    }
                    
                    progressline.moveToPoint(CGPointMake(x, y))
                }
                
                linePointsArray.addObject(PNValue(point: CGPointMake(x, y)))
                
                
            }
            
            pathPoints.addObject(linePointsArray)
            
            // setup the color of the chart line
            if chartData.color != UIColor.blackColor() {
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
    
    override public func drawRect(rect: CGRect)
    {
        if showCoordinateAxis {
            
            var yAsixOffset:CGFloat = 10.0
            
            var ctx:CGContextRef = UIGraphicsGetCurrentContext()
            UIGraphicsPushContext(ctx)
            CGContextSetLineWidth(ctx, axisWidth)
            CGContextSetStrokeColorWithColor(ctx, axisColor.CGColor)
            
            var xAxisWidth:CGFloat = CGRectGetWidth(rect) - chartMargin/2.0
            var yAxisHeight:CGFloat = chartMargin + chartCavanHeight!
            
            // draw coordinate axis
            CGContextMoveToPoint(ctx, chartMargin + yAsixOffset, 0)
            CGContextAddLineToPoint(ctx, chartMargin + yAsixOffset, yAxisHeight)
            CGContextAddLineToPoint(ctx, xAxisWidth, yAxisHeight)
            CGContextStrokePath(ctx)
            
            // draw y axis arrow
            CGContextMoveToPoint(ctx, chartMargin + yAsixOffset - 3, 6)
            CGContextAddLineToPoint(ctx, chartMargin + yAsixOffset, 0)
            CGContextAddLineToPoint(ctx, chartMargin + yAsixOffset + 3, 6)
            CGContextStrokePath(ctx);
            
            // draw x axis arrow
            CGContextMoveToPoint(ctx, xAxisWidth - 6, yAxisHeight - 3)
            CGContextAddLineToPoint(ctx, xAxisWidth, yAxisHeight)
            CGContextAddLineToPoint(ctx, xAxisWidth - 6, yAxisHeight + 3);
            CGContextStrokePath(ctx)
            
            if showLabel{
                
                // draw x axis separator
                var point:CGPoint!
                for var i:Int = 0; i < xLabels.count; ++i {
                    point = CGPointMake(2 * chartMargin +  ( CGFloat(i) * xLabelWidth), chartMargin + chartCavanHeight!)
                    CGContextMoveToPoint(ctx, point.x, point.y - 2)
                    CGContextAddLineToPoint(ctx, point.x, point.y)
                    CGContextStrokePath(ctx)
                }
                
                // draw y axis separator
                var yStepHeight:CGFloat = chartCavanHeight! / CGFloat(yLabelNum)
                for var i:Int = 0; i < xLabels.count; ++i {
                    point = CGPointMake(chartMargin + yAsixOffset, (chartCavanHeight! - CGFloat(i) * yStepHeight + yLabelHeight/2.0
                        ))
                    CGContextMoveToPoint(ctx, point.x, point.y)
                    CGContextAddLineToPoint(ctx, point.x + 2, point.y)
                    CGContextStrokePath(ctx)
                }
            }
            
            var font:UIFont = UIFont.systemFontOfSize(11)
            // draw y unit
            if yUnit != nil{
                var height:CGFloat = heightOfString(yUnit, width: 30.0, font: font)
                var drawRect:CGRect = CGRectMake(chartMargin + 10 + 5, 0, 30.0, height)
                drawTextInContext(ctx, text:yUnit, rect:drawRect, font:font)
            }
            
            // draw x unit
            if xUnit != nil {
                var height:CGFloat = heightOfString(yUnit, width:30.0, font:font)
                var drawRect:CGRect = CGRectMake(CGRectGetWidth(rect) - chartMargin + 5, chartMargin + chartCavanHeight! - height/2, 25.0, height)
                drawTextInContext(ctx, text:yUnit, rect:drawRect, font:font)
            }
        }
        
        super.drawRect(rect)
    }
    
    func heightOfString(text: NSString!, width: CGFloat, font: UIFont) -> CGFloat{
        var ch:CGFloat!
        var size:CGSize = CGSizeMake(width, CGFloat.max)

        var tdic:NSDictionary = NSDictionary(objects: [font, NSFontAttributeName], forKeys: [])
        size = text.boundingRectWithSize(size, options: NSStringDrawingOptions.UsesFontLeading , attributes: tdic as [NSObject : AnyObject], context: nil).size
        ch = size.height
        return ch

    }
    
    func drawTextInContext(ctx: CGContextRef, text: NSString!, rect: CGRect, font:UIFont){
        var priceParagraphStyle:NSMutableParagraphStyle = NSParagraphStyle.defaultParagraphStyle() as! NSMutableParagraphStyle
        priceParagraphStyle.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        priceParagraphStyle.alignment = NSTextAlignment.Left
        
        text.drawInRect(rect, withAttributes: [ NSParagraphStyleAttributeName:priceParagraphStyle, NSFontAttributeName:font] )
    }
    
    // MARK: Init

    override public init(frame: CGRect){
        super.init(frame: frame)
        setDefaultValues()
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
