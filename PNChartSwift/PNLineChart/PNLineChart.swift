//
//  PNLineChart.swift
//  PNChart-Swift
//
//  Created by kevinzhow on 6/4/14.
//  Copyright (c) 2014 Catch Inc. All rights reserved.
//

import UIKit
import QuartzCore


open class PNLineChart: UIView{
    
    open var xLabels: NSArray = []{
        didSet{
            
            if showLabel {
                
                xLabelWidth = chartCavanWidth! / CGFloat(xLabels.count)
                
                for index in 0 ..< xLabels.count += 1 {
                    let labelText = xLabels[index] as! NSString
                    let labelX = 2.0 * chartMargin +  ( CGFloat(index) * xLabelWidth) - (xLabelWidth / 2.0)
                    let label:PNChartLabel = PNChartLabel(frame: CGRect(x:  labelX, y: chartMargin + chartCavanHeight!, width: xLabelWidth, height: chartMargin))
                    label.textAlignment = NSTextAlignment.center
                    label.text = labelText as String
                    addSubview(label)
                }
            }else {
                xLabelWidth = frame.size.width / CGFloat(xLabels.count)
            }
        }
    }
    
    open var yLabels: NSArray = []{
        didSet{

            yLabelNum = CGFloat(yLabels.count)
            let yStep:CGFloat = (yValueMax - yValueMin) / CGFloat(yLabelNum)
            let yStepHeight:CGFloat  = chartCavanHeight! / CGFloat(yLabelNum)
            
            var index:CGFloat = 0

            for _ in yLabels
            {
                
                
                let labelY = chartCavanHeight - (index * yStepHeight)
                let label: PNChartLabel = PNChartLabel(frame: CGRect(x: 0.0, y: CGFloat(labelY), width: CGFloat(chartMargin + 5.0), height: CGFloat(yLabelHeight) ) )
                label.textAlignment = NSTextAlignment.right
                label.text = NSString(format:yLabelFormat, Double(yValueMin + (yStep * index))) as String
                index += 1
                addSubview(label)
            }
        }
    }
    
    /**
    * Array of `LineChartData` objects, one for each line.
    */
    
    open var chartData: NSArray = []{
        didSet{
            let yLabelsArray:NSMutableArray = NSMutableArray(capacity: chartData.count)
            var yMax:CGFloat = 0.0
            var yMin:CGFloat = CGFloat.greatestFiniteMagnitude
            var yValue:CGFloat!
            
            // remove all shape layers before adding new ones
            for layer : Any in chartLineArray{
                (layer as! CALayer).removeFromSuperlayer()
            }
            for layer : Any in chartPointArray {
                (layer as! CALayer).removeFromSuperlayer()
            }
            
            chartLineArray = NSMutableArray(capacity: chartData.count)
            chartPointArray = NSMutableArray(capacity: chartData.count)
            
            // set for point stoken
            let circle_stroke_width:CGFloat = 2.0
            let line_width:CGFloat = 3.0
            
            for chart : Any in chartData{
                // create as many chart line layers as there are data-lines
                let chartObj = chart as! PNLineChartData
                let chartLine:CAShapeLayer = CAShapeLayer()
                chartLine.lineCap       = kCALineCapButt
                chartLine.lineJoin      = kCALineJoinMiter
                chartLine.fillColor     = UIColor.white.cgColor
                chartLine.lineWidth     = line_width
                chartLine.strokeEnd     = 0.0
                layer.addSublayer(chartLine)
                chartLineArray.add(chartLine)
                
                // create point
                let pointLayer:CAShapeLayer = CAShapeLayer()
                pointLayer.strokeColor   = chartObj.color.cgColor
                pointLayer.lineCap       = kCALineCapRound
                pointLayer.lineJoin      = kCALineJoinBevel
                pointLayer.fillColor     = nil
                pointLayer.lineWidth     = circle_stroke_width
                layer.addSublayer(pointLayer)
                chartPointArray.add(pointLayer)
                
                for var i = 0; i < chartObj.itemCount; ++i{
                    yValue = CGFloat(chartObj.getData(i).y)
                    yLabelsArray.add(NSString(format: "%2f", yValue))
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
                print("show y label")
                yLabels = yLabelsArray as NSArray
            }
            
            setNeedsDisplay()
            
        }
    }
    
    var pathPoints: NSMutableArray = []
    
    //For X
    
    open var xLabelWidth:CGFloat = 0.0
    
    //For Y
    
    open var yValueMax:CGFloat = 10.0
    
    open var yValueMin:CGFloat = 1.0
    
    open var yLabelNum:CGFloat = 0.0
    
    open var yLabelHeight:CGFloat = 12.0
    
    //For Chart
    
    open var chartCavanHeight:CGFloat!
    
    open var chartCavanWidth:CGFloat!
    
    open var chartMargin:CGFloat = 25.0
    
    open var showLabel: Bool = true
    
    open var showCoordinateAxis: Bool = true
    
    // For Axis
    
    open var axisColor:UIColor = PNGreyColor
    
    open var axisWidth:CGFloat = 1.0
    
    open var xUnit: NSString!
    
    open var yUnit: NSString!
    
    /**
    *  String formatter for float values in y labels. If not set, defaults to @"%1.f"
    */
    
    open var yLabelFormat:NSString = "%1.f"
    
    var chartLineArray: NSMutableArray = []  // Array[CAShapeLayer]
    var chartPointArray: NSMutableArray = [] // Array[CAShapeLayer] save the point layer
    
    var chartPaths: NSMutableArray = []     // Array of line path, one for each line.
    var pointPaths: NSMutableArray = []       // Array of point path, one for each line
    
    open var delegate:PNChartDelegate?
    

    // MARK: Functions 
    
    func setDefaultValues() {
        backgroundColor = UIColor.white
        clipsToBounds = true
        chartLineArray = NSMutableArray()
        showLabel = false
        pathPoints = NSMutableArray()
        isUserInteractionEnabled = true
        
        chartCavanWidth = frame.size.width - (chartMargin * 2.0)
        chartCavanHeight = frame.size.height - (chartMargin * 2.0)
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        touchPoint(touches as NSSet!, withEvent: event)
        touchKeyPoint(touches as NSSet!, withEvent: event)
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        touchPoint(touches as NSSet!, withEvent: event)
        touchKeyPoint(touches as NSSet!, withEvent: event)
    }
    
    func touchPoint(_ touches: NSSet!, withEvent event: UIEvent!){
        let touch:UITouch = touches.Any() as! UITouch
        let touchPoint = touch.location(in: self)
        
        for linePoints:Any in pathPoints {
            let linePointsArray = linePoints as! NSArray
            
            for var i:NSInteger = 0; i < (linePointsArray.count - 1); i += 1{

                let p1:CGPoint = (linePointsArray[i] as! PNValue).point
                let p2:CGPoint = (linePointsArray[i+1] as! PNValue).point
                

                
                // Closest distance from point to line
                var distance:CGFloat = fabs(((p2.x - p1.x) * (touchPoint.y - p1.y)) - ((p1.x - touchPoint.x) * (p1.y - p2.y)))
                distance =  distance /  hypot( p2.x - p1.x,  p1.y - p2.y )
                

                if distance <= 5.0 {
                    // Conform to delegate parameters, figure out what bezier path this CGPoint belongs to.

                    for path : Any in chartPaths {
                        
                        let pointContainsPath:Bool = CGPathContainsPoint((path as! UIBezierPath).cgPath, nil, p1, false)

                        if pointContainsPath {

                            delegate?.userClickedOnLinePoint(touchPoint , lineIndex: chartPaths.index(of: path))
                        }
                    }
                }

                
            }
            
            
        }
    }
    
    
    func touchKeyPoint(_ touches: NSSet!, withEvent event: UIEvent!){
        let touch:UITouch = touches.Any() as! UITouch
        let touchPoint = touch.location(in: self)
        
        for linePoints: Any in pathPoints {
            let linePointsArray: NSArray = pathPoints as NSArray
            
            for var i:NSInteger = 0; i < (linePointsArray.count - 1); i += 1{
                let p1:CGPoint = (linePointsArray[i] as! PNValue).point
                let p2:CGPoint = (linePointsArray[i+1] as! PNValue).point
                
                let distanceToP1: CGFloat = fabs( CGFloat( hypot( touchPoint.x - p1.x , touchPoint.y - p1.y ) ))
                let distanceToP2: CGFloat = hypot( touchPoint.x - p2.x, touchPoint.y - p2.y)
                
                let distance: CGFloat = fmin(distanceToP1, distanceToP2)

                if distance <= 10.0 {

                    delegate?.userClickedOnLineKeyPoint(touchPoint , lineIndex: pathPoints.index(of: linePoints) ,keyPointIndex:(distance == distanceToP2 ? i + 1 : i) )
                }
            }
        }

    }
    
    /**
    * This method will call and troke the line in animation
    */
    
    open func strokeChart(){
        chartPaths = NSMutableArray()
        pointPaths = NSMutableArray()
            
            //Draw each line
        for lineIndex in 0 ..< chartData.count {
            let chartData:PNLineChartData = self.chartData[lineIndex] as! PNLineChartData
            let chartLine:CAShapeLayer = chartLineArray[lineIndex] as! CAShapeLayer
            let pointLayer:CAShapeLayer = chartPointArray[lineIndex] as! CAShapeLayer
                
            var yValue:CGFloat?
            var innerGrade:CGFloat?
                
            UIGraphicsBeginImageContext(frame.size)
                
            let progressline:UIBezierPath = UIBezierPath()
            progressline.lineWidth = chartData.lineWidth
            progressline.lineCapStyle = CGLineCap.round
            progressline.lineJoinStyle = CGLineJoin.round
                
            let pointPath:UIBezierPath = UIBezierPath()
            pointPath.lineWidth = chartData.lineWidth
            chartPaths.add(progressline)
            pointPaths.add(pointPath)
                
            if !showLabel {
                chartCavanHeight = frame.size.height - 2 * yLabelHeight
                chartCavanWidth = frame.size.width
                chartMargin = 0.0
                xLabelWidth = (chartCavanWidth! / CGFloat(xLabels.count - 1))
            }
            
            let linePointsArray:NSMutableArray = NSMutableArray()
                
            var last_x:CGFloat = 0.0
            var last_y:CGFloat = 0.0
            let inflexionWidth:CGFloat = chartData.inflexionPointWidth
                
            for i:Int in 0 ..< chartData.itemCount {
                yValue = CGFloat(chartData.getData(i).y)
                    
                innerGrade = (yValue! - yValueMin) / (yValueMax - yValueMin)
                    
                let x:CGFloat = 2.0 * chartMargin +  (CGFloat(i) * xLabelWidth)
                let y:CGFloat = chartCavanHeight! - (innerGrade! * chartCavanHeight!) + (yLabelHeight / 2.0)
                    
                // cycle style point
                switch chartData.inflexionPointStyle{
                case PNLineChartData.PNLineChartPointStyle.pnLineChartPointStyleCycle:
                    
                    let circleRect:CGRect = CGRect(x: x-inflexionWidth/2.0, y: y-inflexionWidth/2.0, width: inflexionWidth,height: inflexionWidth)
                    let circleCenter:CGPoint = CGPoint(x: circleRect.origin.x + (circleRect.size.width / 2.0), y: circleRect.origin.y + (circleRect.size.height / 2.0))
                    pointPath.move(to: CGPoint(x: circleCenter.x + (inflexionWidth/2), y: circleCenter.y))
                    pointPath.addArc(withCenter: circleCenter, radius: CGFloat(inflexionWidth/2.0), startAngle: 0.0, endAngle:CGFloat(2.0*M_PI), clockwise: true)
                    
                    if i != 0 {
                        
                        // calculate the point for line
                        let distance:CGFloat = sqrt( pow( x-last_x, 2.0) + pow( y-last_y,2.0) )
                        let last_x1:CGFloat = last_x + (inflexionWidth/2) / distance * (x-last_x)
                        let last_y1:CGFloat = last_y + (inflexionWidth/2) / distance * (y-last_y)
                        let x1:CGFloat = x - (inflexionWidth/2) / distance * (x-last_x)
                        let y1:CGFloat = y - (inflexionWidth/2) / distance * (y-last_y)
                        progressline.move(to: CGPoint(x: last_x1, y: last_y1))
                        progressline.addLine(to: CGPoint(x: x1, y: y1))
                    }
                    last_x = x
                    last_y = y
                    
                // Square style point
                case PNLineChartData.PNLineChartPointStyle.pnLineChartPointStyleSquare:
                    
                    let squareRect:CGRect = CGRect(x: x-inflexionWidth/2, y: y-inflexionWidth/2, width: inflexionWidth,height: inflexionWidth)
                    let squareCenter:CGPoint = CGPoint(x: squareRect.origin.x + (squareRect.size.width / 2), y: squareRect.origin.y + (squareRect.size.height / 2))
                    
                    pointPath.move(to: CGPoint(x: squareCenter.x - (inflexionWidth/2), y: squareCenter.y - (inflexionWidth/2)))
                    pointPath.addLine(to: CGPoint(x: squareCenter.x + (inflexionWidth/2), y: squareCenter.y - (inflexionWidth/2)))
                    pointPath.addLine(to: CGPoint(x: squareCenter.x + (inflexionWidth/2), y: squareCenter.y + (inflexionWidth/2)))
                    pointPath.addLine(to: CGPoint(x: squareCenter.x - (inflexionWidth/2), y: squareCenter.y + (inflexionWidth/2)))
                    pointPath.close()
                    
                    if i != 0{
                        
                        // calculate the point for line
                        let distance:CGFloat = sqrt( pow(x-last_x, 2) + pow(y-last_y,2) )
                        let last_x1:CGFloat = last_x + (inflexionWidth/2)
                        let last_y1:CGFloat = last_y + (inflexionWidth/2) / distance * (y-last_y)
                        let x1:CGFloat = x - (inflexionWidth/2)
                        let y1:CGFloat = y - (inflexionWidth/2) / distance * (y-last_y)
                        
                        progressline.move(to: CGPoint(x: last_x1, y: last_y1))
                        progressline.addLine(to: CGPoint(x: x1, y: y1))
                    }
                    
                    last_x = x
                    last_y = y
                    
                // Triangle style point
                case PNLineChartData.PNLineChartPointStyle.pnLineChartPointStyleTriangle:
                    
                    if i != 0 {
                        progressline.addLine(to: CGPoint(x: x, y: y))
                    }
                    
                    progressline.move(to: CGPoint(x: x, y: y))
                    
                default:
                    
                    if i != 0 {
                        progressline.addLine(to: CGPoint(x: x, y: y))
                    }
                    
                    progressline.move(to: CGPoint(x: x, y: y))
                }
                
                linePointsArray.add(PNValue(point: CGPoint(x: x, y: y)))
                
                
            }
            
            pathPoints.add(linePointsArray)
            
            // setup the color of the chart line
            if chartData.color != UIColor.black {
                chartLine.strokeColor = chartData.color.cgColor
                pointLayer.strokeColor = chartData.color.cgColor
            }
            else {
                chartLine.strokeColor = PNGreenColor.cgColor
                pointLayer.strokeColor = PNGreenColor.cgColor
            }
            
            progressline.stroke()
            
            chartLine.path = progressline.cgPath
            pointLayer.path = pointPath.cgPath
            
            
            CATransaction.begin()
            let pathAnimation:CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
            pathAnimation.duration = 1.0
            pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            pathAnimation.fromValue = 0.0
            pathAnimation.toValue   = 1.0
            
            chartLine.add(pathAnimation, forKey:"strokeEndAnimation")
            chartLine.strokeEnd = 1.0
            
            // if you want cancel the point animation, conment this code, the point will show immediately
            if chartData.inflexionPointStyle != PNLineChartData.PNLineChartPointStyle.pnLineChartPointStyleNone {
                pointLayer.add(pathAnimation, forKey:"strokeEndAnimation")
            }
            
            CATransaction.commit()
            
            UIGraphicsEndImageContext()
        }
        
    }
    
    override open func draw(_ rect: CGRect)
    {
        if showCoordinateAxis {
            
            let yAsixOffset:CGFloat = 10.0
            
            let ctx:CGContext = UIGraphicsGetCurrentContext()!
            UIGraphicsPushContext(ctx)
            ctx.setLineWidth(axisWidth)
            ctx.setStrokeColor(axisColor.cgColor)
            
            let xAxisWidth:CGFloat = rect.width - chartMargin/2.0
            let yAxisHeight:CGFloat = chartMargin + chartCavanHeight!
            
            // draw coordinate axis
            ctx.move(to: CGPoint(x: chartMargin + yAsixOffset, y: 0))
            ctx.addLine(to: CGPoint(x: chartMargin + yAsixOffset, y: yAxisHeight))
            ctx.addLine(to: CGPoint(x: xAxisWidth, y: yAxisHeight))
            ctx.strokePath()
            
            // draw y axis arrow
            ctx.move(to: CGPoint(x: chartMargin + yAsixOffset - 3, y: 6))
            ctx.addLine(to: CGPoint(x: chartMargin + yAsixOffset, y: 0))
            ctx.addLine(to: CGPoint(x: chartMargin + yAsixOffset + 3, y: 6))
            ctx.strokePath();
            
            // draw x axis arrow
            ctx.move(to: CGPoint(x: xAxisWidth - 6, y: yAxisHeight - 3))
            ctx.addLine(to: CGPoint(x: xAxisWidth, y: yAxisHeight))
            ctx.addLine(to: CGPoint(x: xAxisWidth - 6, y: yAxisHeight + 3));
            ctx.strokePath()
            
            if showLabel{
                
                // draw x axis separator
                var point:CGPoint!
                for i:Int in 0 ..< xLabels.count += 1 {
                    point = CGPoint(x: 2 * chartMargin +  ( CGFloat(i) * xLabelWidth), y: chartMargin + chartCavanHeight!)
                    ctx.move(to: CGPoint(x: point.x, y: point.y - 2))
                    ctx.addLine(to: CGPoint(x: point.x, y: point.y))
                    ctx.strokePath()
                }
                
                // draw y axis separator
                let yStepHeight:CGFloat = chartCavanHeight! / CGFloat(yLabelNum)
                for i:Int in 0 ..< xLabels.count += 1 {
                    point = CGPoint(x: chartMargin + yAsixOffset, y: (chartCavanHeight! - CGFloat(i) * yStepHeight + yLabelHeight/2.0
                        ))
                    ctx.move(to: CGPoint(x: point.x, y: point.y))
                    ctx.addLine(to: CGPoint(x: point.x + 2, y: point.y))
                    ctx.strokePath()
                }
            }
            
            let font:UIFont = UIFont.systemFont(ofSize: 11)
            // draw y unit
            if yUnit != nil{
                let height:CGFloat = heightOfString(yUnit, width: 30.0, font: font)
                let drawRect:CGRect = CGRect(x: chartMargin + 10 + 5, y: 0, width: 30.0, height: height)
                drawTextInContext(ctx, text:yUnit, rect:drawRect, font:font)
            }
            
            // draw x unit
            if xUnit != nil {
                let height:CGFloat = heightOfString(yUnit, width:30.0, font:font)
                let drawRect:CGRect = CGRect(x: rect.width - chartMargin + 5, y: chartMargin + chartCavanHeight! - height/2, width: 25.0, height: height)
                drawTextInContext(ctx, text:yUnit, rect:drawRect, font:font)
            }
        }
        
        super.draw(rect)
    }
    
    func heightOfString(_ text: NSString, width: CGFloat, font: UIFont) -> CGFloat{
        let size : CGSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let rect : CGRect = text.boundingRect(with: size, options: NSStringDrawingOptions.usesFontLeading , attributes: [NSFontAttributeName : font], context: nil)
        return rect.size.height
    }
    
    func drawTextInContext(_ ctx: CGContext, text: NSString!, rect: CGRect, font:UIFont){
        let priceParagraphStyle:NSMutableParagraphStyle = NSParagraphStyle.default as! NSMutableParagraphStyle
        priceParagraphStyle.lineBreakMode = NSLineBreakMode.byTruncatingTail
        priceParagraphStyle.alignment = NSTextAlignment.left
        
        text.draw(in: rect, withAttributes: [ NSParagraphStyleAttributeName:priceParagraphStyle, NSFontAttributeName:font] )
    }
    
    // MARK: Init

    override public init(frame: CGRect){
        super.init(frame: frame)
        setDefaultValues()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
