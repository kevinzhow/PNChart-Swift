//
//  PNLineChart.swift
//  PNChartSwift
//
//  Created by YiChen Zhou on 11/10/16.
//  Copyright © 2016 YiChen Zhou. All rights reserved.
//

import UIKit
import QuartzCore

class PNLineChart: UIView{
    public var xLabels: NSArray = []{
        didSet {
            if self.showLabel {
                self.xLabelWidth = self.chartCavanWidth/CGFloat(self.xLabels.count)
                for index in 0..<self.xLabels.count {
                    let labelText = self.xLabels[index] as! String
                    let labelX = 2 * self.chartMargin + (CGFloat(index) * self.xLabelWidth) - (self.xLabelWidth/2)
                    let label: PNChartLabel = PNChartLabel(frame: CGRect(x: CGFloat(labelX), y: CGFloat(self.chartMargin + self.chartCavanHeight), width: CGFloat(self.xLabelWidth), height: CGFloat(self.chartMargin)))
                    label.textAlignment = NSTextAlignment.center
                    label.text = labelText
                    self.addSubview(label)
                }
            } else {
                self.xLabelWidth = frame.size.width / CGFloat(self.xLabels.count)
            }
        }
    }
    
    public var yLabels: NSArray = []{
        didSet {
            self.yLabelNum = CGFloat(self.yLabels.count)
            let ySetp: CGFloat = (self.yValueMax - self.yValueMin) / CGFloat(self.yLabelNum)
            let yStepHeight: CGFloat = self.chartCavanHeight / CGFloat(self.yLabelNum)
            
            var index: CGFloat = 0
            
            for _ in yLabels {
                let labelY = self.chartCavanHeight - (index * yStepHeight)
                let label: PNChartLabel = PNChartLabel(frame: CGRect(x: CGFloat(0), y: labelY, width: self.chartMargin + 5, height: CGFloat(yLabelHeight)))
                label.textAlignment = .right
                label.text = String(format: self.yLabelFormat, Double(self.yValueMin + (ySetp * index)))
                index += 1
                self.addSubview(label)
            }
        }
    }
    
    // Array of LineChartData objects, one for eacg line
    public var chartData: NSArray = []{
        didSet{
            let yLabelsArray: NSMutableArray = NSMutableArray(capacity: self.chartData.count)
            var yMax: CGFloat = 0
            var yMin: CGFloat = CGFloat.infinity
            var yValue: CGFloat!
            
            // remove all shape layers before adding new ones
            for layer in self.chartLineArray {
                (layer as! CALayer).removeFromSuperlayer()
            }
            
            for layer in self.chartPointArray {
                (layer as! CALayer).removeFromSuperlayer()
            }
            
            self.chartLineArray = NSMutableArray(capacity: self.chartData.count)
            self.chartPointArray = NSMutableArray(capacity: self.chartData.count)
            
            // Set for point stroken
            let circleStrokeWidth: CGFloat = 2
            let lineWidth: CGFloat = 3
            
            for chart in self.chartData {
                // Create as many chart line layers as number of data
                let chartObj = chart as! PNLineChartData
                let chartLine: CAShapeLayer = CAShapeLayer()
				chartLine.lineCap = CAShapeLayerLineCap.butt
				chartLine.lineJoin = CAShapeLayerLineJoin.miter
                chartLine.fillColor = UIColor.white.cgColor
                chartLine.lineWidth = lineWidth
                chartLine.strokeEnd = 0
                layer.addSublayer(chartLine)
                self.chartLineArray.add(chartLine)
                
                // Create as many chart point layers as number of data
                let pointLayer: CAShapeLayer = CAShapeLayer()
                pointLayer.strokeColor = chartObj.color.cgColor
				pointLayer.lineCap = CAShapeLayerLineCap.round
				pointLayer.lineJoin = CAShapeLayerLineJoin.bevel
                pointLayer.fillColor = nil
                pointLayer.lineWidth = circleStrokeWidth
                layer.addSublayer(pointLayer)
                self.chartPointArray.add(pointLayer)
                
                for index in 0..<chartObj.itemCount {
                    yValue = CGFloat(chartObj.getData(index).y)
                    yLabelsArray.add(String(format: "%2f", yValue))
                    yMax = fmax(yMax, yValue)
                    yMin = fmin(yMin, yValue)
                }
            }
            
            // Min value for Y label
            if yMax < 5 {
                yMax = 5.0
            }
            
            if yMin < 0 {
                yMin = 0.0
            }
            
            self.yValueMin = yMin
            self.yValueMax = yMax
            
            if self.showLabel {
                self.yLabels = yLabelsArray as NSArray
            }
            
            setNeedsDisplay()
        }
    }
    
    var pathPoints: NSMutableArray = []
    
    // X-Axis Info
    public var xLabelWidth: CGFloat = 0
    
    // Y-Axis Info
    public var yValueMax: CGFloat = 10
    public var yValueMin: CGFloat = 1
    public var yLabelNum: CGFloat = 0
    public var yLabelHeight: CGFloat = 12
    
    // Chart Info
    public var showLabel: Bool = true
    public var showCoordinateAxis: Bool = true
    public var chartCavanHeight: CGFloat = {
        return CGFloat(0)
        
    }()
    public var chartCavanWidth: CGFloat = {
        return CGFloat(0)
    }()
    public var chartMargin: CGFloat = 25
    
    // For Axis
    public var axisColor: UIColor = PNGrey
    public var axisWidth: CGFloat = 1
    public var xUnit: NSString!
    public var yUnit: NSString!
    
    // String Format for float values in y labels.
    public var yLabelFormat = "%1.1f"
    var chartLineArray: NSMutableArray = []
    var chartPointArray: NSMutableArray = []
    
    var chartPaths: NSMutableArray = []
    var pointPaths: NSMutableArray = []
    
    // Initialize Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setDefaultValues()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Functions
    
    func setDefaultValues() {
        self.backgroundColor = UIColor.white
        self.clipsToBounds = true
        self.chartLineArray = NSMutableArray()
        self.showLabel = false
        self.pathPoints = NSMutableArray()
        self.isUserInteractionEnabled = true
        
        self.chartCavanWidth = self.frame.size.width - (chartMargin * 2)
        self.chartCavanHeight = self.frame.size.height - (chartMargin * 2)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchPoint(touches: touches as NSSet, withEvent: event!)
        self.touchKeyPoint(touches: touches as NSSet, withEvent: event!)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchPoint(touches: touches as NSSet, withEvent: event!)
        self.touchKeyPoint(touches: touches as NSSet, withEvent: event!)
    }
    
    func touchPoint(touches: NSSet, withEvent event: UIEvent) {
        let touch: UITouch = touches.anyObject() as! UITouch
        let touchPoint = touch.location(in: self)
        
        for linePoints in self.pathPoints {
            let linePointsArray = linePoints as! [PNValue]
            for index in 0..<(linePointsArray.count - 1) {
                let p1: CGPoint = (linePointsArray[index]).point
                let p2: CGPoint = (linePointsArray[index + 1]).point
                // The closest distance from point to value
				var distance: CGFloat = abs(((p2.x - p1.x) * (touchPoint.y - p1.y)) - ((p1.x - touchPoint.x) * (p1.y - p2.y)))
                distance = distance / hypot(p2.x - p1.x, p1.y - p2.y)
                if distance <= 5 {
                    for path in self.chartPaths {
                        if (path as AnyObject).contains(p1) {
                            self.userClickedOnLinePoint(point: touchPoint, lineIndex: self.chartPaths.index(of: path))
                        }
                    }
                }
            }
        }
    }
    
    func touchKeyPoint(touches: NSSet, withEvent event: UIEvent) {
        let touch: UITouch = touches.anyObject() as! UITouch
        let touchPoint = touch.location(in: self)
        
        for linePoints in pathPoints {
            let linePointsArray = pathPoints as! [PNValue]
            
            for index in 0..<(linePointsArray.count - 1) {
                let p1: CGPoint = (linePointsArray[index]).point
                let p2: CGPoint = (linePointsArray[index + 1]).point
                
				let distanceToP1: CGFloat = abs(CGFloat(hypot(touchPoint.x - p1.x , touchPoint.y - p1.y )))
                let distanceToP2: CGFloat = hypot( touchPoint.x - p2.x, touchPoint.y - p2.y)
                
                let distance: CGFloat = fmin(distanceToP1, distanceToP2)
                if distance <= 10 {
                    self.userClickedOnLineKeyPoint(point: touchPoint, lineIndex: self.pathPoints.index(of: linePoints), keyPointIndex: (distance == distanceToP2 ? index + 1 : index))
                }
            }
        }
    }
    
    // This method will be called and stroke the line in animation
    func strokeChart() {
        let chartPaths = NSMutableArray()
        let pointPaths = NSMutableArray()
        
        for lineIndex in 0..<chartData.count {
            let chartData: PNLineChartData = self.chartData[lineIndex] as! PNLineChartData
            let chartLine = chartLineArray[lineIndex] as! CAShapeLayer
            let pointLayer = chartPointArray[lineIndex] as! CAShapeLayer
            
            var yValue: CGFloat!
            var innerGrade: CGFloat!
            
            UIGraphicsBeginImageContext(self.frame.size)
            
            let progressLine = UIBezierPath()
            progressLine.lineWidth = chartData.lineWidth
            progressLine.lineCapStyle = .round
            progressLine.lineJoinStyle = .round
            
            let pointPath = UIBezierPath()
            pointPath.lineWidth = chartData.lineWidth
            
            chartPaths.add(progressLine)
            pointPaths.add(pointPath)
            
            if !(self.showLabel) {
                self.chartCavanHeight = self.frame.size.height - 2 * self.yLabelHeight
                self.chartCavanWidth = self.frame.size.width
                self.chartMargin = 0
                self.xLabelWidth = (self.chartCavanWidth / CGFloat(self.xLabels.count - 1))
            }
            
            let linePointsArray = NSMutableArray()
            
            var lastX: CGFloat = 0
            var lastY: CGFloat = 0
            let inflexionWidth = chartData.inflexionPointWidth
            
            for index in 0..<chartData.itemCount {
                yValue = CGFloat(chartData.getData(index).y)
                innerGrade = (yValue - self.yValueMin) / (self.yValueMax - self.yValueMin)
                
                let x: CGFloat = self.chartMargin * 2 + (CGFloat(index) * self.xLabelWidth)
                let y: CGFloat = self.chartCavanHeight - (innerGrade * self.chartCavanHeight)
                
                switch chartData.inflexPointStyle {
                // Cycle Style Point
                case .Cycle:
                    let circleRect = CGRect(x: x - inflexionWidth/2, y: y - inflexionWidth/2, width: inflexionWidth, height: inflexionWidth)
                    let circleCenter = CGPoint(x: circleRect.origin.x + circleRect.size.width/2, y: circleRect.origin.y + circleRect.size.height/2)
                    pointPath.move(to: CGPoint(x: circleCenter.x + inflexionWidth/2, y: circleCenter.y))
                    pointPath.addArc(withCenter: circleCenter, radius: CGFloat(inflexionWidth/2), startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
                    
                    if index != 0 {
                        // Calculate the point for line
                        let distance = CGFloat(sqrt(pow(Double(x - lastX), 2) + pow(Double(y - lastY), 2)))
                        let lastX1 = lastX + (inflexionWidth/2) / distance * (x - lastX)
                        let lastY1 = lastY + (inflexionWidth/2) / distance * (y - lastY)
                        let x1 = x - (inflexionWidth/2) / distance * (x - lastX)
                        let y1 = y - (inflexionWidth/2) / distance * (y - lastY)
                        progressLine.move(to: CGPoint(x: lastX1, y: lastY1))
                        progressLine.addLine(to: CGPoint(x: x1, y: y1))
                    }
                    
                    lastX = x
                    lastY = y
                    
                // Square Style Point
                case .Square:
                    let squareRect = CGRect(x: x - inflexionWidth/2, y: y - inflexionWidth/2, width: inflexionWidth, height: inflexionWidth)
                    let squareCenter = CGPoint(x: squareRect.origin.x + (squareRect.size.width/2), y: squareRect.origin.y  + (squareRect.size.height/2))
                    pointPath.move(to: CGPoint(x: squareCenter.x - (inflexionWidth/2), y: squareCenter.y - (inflexionWidth/2)))
                    pointPath.addLine(to: CGPoint(x: squareCenter.x + (inflexionWidth/2), y: squareCenter.y - (inflexionWidth/2)))
                    pointPath.addLine(to: CGPoint(x: squareCenter.x + (inflexionWidth/2), y: squareCenter.y + (inflexionWidth/2)))
                    pointPath.addLine(to: CGPoint(x: squareCenter.x - (inflexionWidth/2), y: squareCenter.y + (inflexionWidth/2)))
                    pointPath.close()
                    
                    if index != 0 {
                        // Calculate the point for line
                        let distance = CGFloat(sqrt(pow(x - lastX, 2) + pow(y - lastY, 2)))
                        let lastX1 = lastX + (inflexionWidth / 2)
                        let lastY1 = lastY + (inflexionWidth / 2) / distance * (y - lastY)
                        let x1 = x - (inflexionWidth / 2)
                        let y1 = y - (inflexionWidth / 2) / distance * (y - lastY)
                        
                        progressLine.move(to: CGPoint(x: lastX1, y: lastY1))
                        progressLine.addLine(to: CGPoint(x: x1, y: y1))
                    }
                    
                    lastX = x
                    lastY = y
                    
                // Triangle Style Point
                case .Triangle:
                    if index != 0 {
                        progressLine.addLine(to: CGPoint(x: x, y: y))
                    }
                    
                    progressLine.move(to: CGPoint(x: x, y: y))
                    
                default:
                    if index != 0 {
                        progressLine.addLine(to: CGPoint(x: x, y: y))
                    }
                    
                    progressLine.move(to: CGPoint(x: x, y: y))
                }
                linePointsArray.add(PNValue(point: CGPoint(x: x, y: y)))
            }
            
            pathPoints.add(linePointsArray)
            
            // Setup color for chart line
            if chartData.color != UIColor.black {
                chartLine.strokeColor = chartData.color.cgColor
                pointLayer.strokeColor = chartData.color.cgColor
            } else {
                chartLine.strokeColor = PNGreen.cgColor
                chartLine.strokeColor = PNGreen.cgColor
            }
            
            progressLine.stroke()
            
            chartLine.path = progressLine.cgPath
            pointLayer.path = pointPath.cgPath
            
            CATransaction.begin()
            let path = CABasicAnimation(keyPath: "strokeEnd")
            path.duration = 1
			path.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            path.fromValue = 0
            path.toValue = 1
            
            chartLine.add(path, forKey: "strokeEndAnimation")
            chartLine.strokeEnd = 1
            
            if chartData.inflexPointStyle != .None {
                pointLayer.add(path, forKey: "strokeEndAnimation")
            }
            
            CATransaction.commit()
            UIGraphicsEndImageContext()
        }
    }
    
    override func draw(_ rect: CGRect) {
        if self.showCoordinateAxis {
            let yAxisOffset: CGFloat = 10
            let ctx = UIGraphicsGetCurrentContext()
            UIGraphicsPushContext(ctx!)
            ctx?.setLineWidth(self.axisWidth)
            ctx?.setStrokeColor(self.axisColor.cgColor)
            
            let xAxisWidth: CGFloat = rect.width - self.chartMargin/2
            let yAxisHeight: CGFloat = self.chartMargin + self.chartCavanHeight
            
            // Draw coordinate axis
            ctx?.move(to: CGPoint(x: self.chartMargin + yAxisOffset, y: 0))
            ctx?.addLine(to: CGPoint(x: self.chartMargin + yAxisOffset, y: yAxisHeight))
            ctx?.addLine(to: CGPoint(x: xAxisWidth, y: yAxisHeight))
            ctx?.strokePath()
            
            // Draw y axis arrow
            ctx?.move(to: CGPoint(x: self.chartMargin + yAxisOffset - 3, y: 6))
            ctx?.addLine(to: CGPoint(x: self.chartMargin + yAxisOffset, y: 0))
            ctx?.addLine(to: CGPoint(x: self.chartMargin + yAxisOffset + 3, y: 6))
            ctx?.strokePath()
            
            // Draw x axis arrow
            ctx?.move(to: CGPoint(x: xAxisWidth - 6, y: yAxisHeight - 3))
            ctx?.addLine(to: CGPoint(x: xAxisWidth, y: yAxisHeight))
            ctx?.addLine(to: CGPoint(x: xAxisWidth - 6, y: yAxisHeight + 3))
            ctx?.strokePath()
            
            if self.showLabel {
                // Draw x axis separator
                var point: CGPoint!
                for index in 0..<self.xLabels.count {
                    point = CGPoint(x: 2 * self.chartMargin + CGFloat(index) * self.xLabelWidth, y: self.chartMargin + self.chartCavanHeight)
                    ctx?.move(to: CGPoint(x: point.x, y: point.y - 2))
                    ctx?.addLine(to: CGPoint(x: point.x, y: point.y))
                    ctx?.strokePath()
                }
                
                // Draw y axis separator
                let yStepHeight = self.chartCavanHeight/self.yLabelNum
                for index in 0..<self.xLabels.count {
                    point = CGPoint(x: self.chartMargin + yAxisOffset, y: (self.chartCavanHeight - CGFloat(index) * yStepHeight + self.yLabelHeight/2))
                    ctx?.move(to: CGPoint(x: point.x, y: point.y))
                    ctx?.addLine(to: CGPoint(x: point.x + 2, y: point.y))
                    ctx?.strokePath()
                }
            }
            
            let font = UIFont(name: "Avenir-Medium", size: 11)
            
            // Draw y unit
            if self.yUnit != nil {
                let height = self.heightOfString(text: self.yUnit, width: 30, font: font!)
                let drawRect = CGRect(x: self.chartMargin + 15, y: 0, width: 30, height: height)
                self.drawTextInContext(ctx: ctx!, text: self.yUnit, rect: drawRect, font: font!)
            }
            
            if self.xUnit != nil {
                let height = self.heightOfString(text: self.xUnit, width: 30, font: font!)
                let drawRect = CGRect(x: rect.width - self.chartMargin + 5, y: self.chartMargin + self.chartCavanHeight - height/2, width: 25, height: height)
                self.drawTextInContext(ctx: ctx!, text: self.xUnit, rect: drawRect, font: font!)
            }
        }
        super.draw(rect)
    }
}

extension PNLineChart {
    func heightOfString(text: NSString, width: CGFloat, font: UIFont) -> CGFloat {
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
		let rect = text.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return rect.size.height
    }
    
    func drawTextInContext(ctx: CGContext, text: NSString, rect: CGRect, font: UIFont) {
        let priceParagraphStyle: NSMutableParagraphStyle = NSParagraphStyle.default as! NSMutableParagraphStyle
        priceParagraphStyle.lineBreakMode = .byTruncatingTail
        priceParagraphStyle.alignment = .left
		text.draw(in: rect, withAttributes: [NSAttributedString.Key.paragraphStyle: priceParagraphStyle])
    }
    
    func userClickedOnLineKeyPoint(point: CGPoint, lineIndex: Int, keyPointIndex: Int) {
        print("Click Key on line \(point.x), \(point.y) line index is \(lineIndex) and point index is \(keyPointIndex)")
    }
    
    func userClickedOnLinePoint(point: CGPoint, lineIndex: Int) {
        print("Click Key on line \(point.x), \(point.y) line index is \(lineIndex)")
    }
}
