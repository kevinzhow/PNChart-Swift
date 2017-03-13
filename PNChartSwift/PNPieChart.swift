//
//  PNPieChart.swift
//  PNChartSwift
//
//  Created by YiChen Zhou on 12/27/16.
//  Copyright © 2016 YiChen Zhou. All rights reserved.
//

import UIKit


class PNPieChart: PNGenericChart {
    var items: [PNPieChartDataItem]!
    var endPercentages: [CGFloat]!
    
    var contentView: UIView!
    var pieLayer: CAShapeLayer!
    var descriptionLabels: NSMutableArray!
    
    var sectorHighlight: CAShapeLayer!
    var selectedItems: NSMutableDictionary!
    
    var descriptionTextFont: UIFont!
    var descriptionTextColor: UIColor!
    var descriptionTextShadowColor: UIColor!
    var descriptionTextShadowOffset: CGSize!
    var duration: TimeInterval!
    
    var hideValues: Bool!
    var showOnlyValues: Bool!
    var showAbsoluteValues: Bool!
    
    var showTextShadow: Bool!
    
    // Hide percentage labels less than cutoff value
    var labelPercentageCutoff: CGFloat = 0
    
    // Default as true
    var shouldHighlightSectorOnTouch: Bool!
    
    // Current outer radius. Override recompute() to change this.
    var outerCircleRadius: CGFloat!
    // Current inner radius. Override recompute() to change this.
    var innterCircleRadius: CGFloat!
    
    // Multiple selection
    var enableMultipleSelection: Bool!
    
    init(frame: CGRect, items: [PNPieChartDataItem]) {
        super.init(frame: frame)
        self.items = items
        baseInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        baseInit()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        strokeChart()
    }
    
    func baseInit() {
        contentView = UIView()
        selectedItems = NSMutableDictionary()
        outerCircleRadius = self.bounds.size.width / 2
        innterCircleRadius = self.bounds.size.width / 6
        descriptionTextColor = UIColor.white
        descriptionTextFont = UIFont(name: "Avenir-Medium", size: 14.0)!
        descriptionTextShadowColor = UIColor.darkGray
        descriptionTextShadowOffset = CGSize(width: 0, height: 1)
        duration = 1.0
        
        shouldHighlightSectorOnTouch = true
        enableMultipleSelection = true
        labelPercentageCutoff = 0
        
        hideValues = false
        showOnlyValues = false
        showAbsoluteValues = false
        showTextShadow = false
        
        
        super.setupDefaultValues()
        loadDefault()
    }
    
    func loadDefault() {
        var currentTotal: CGFloat = 0;
        var total: CGFloat = 0
        
        for index in 0..<items.count {
            total = total + items[index].value
        }
        
        endPercentages = [CGFloat]()
        
        for index in 0..<items.count {
            if total == 0 {
                endPercentages.append(CGFloat(1) / CGFloat(items.count * (index + 1)))
            } else {
                currentTotal = currentTotal + items[index].value
                endPercentages.append(currentTotal / total)
            }
        }
        
        contentView.removeFromSuperview()
        contentView = UIView(frame: self.bounds)
        self.addSubview(contentView)
        descriptionLabels = NSMutableArray()
        
        pieLayer = CAShapeLayer(layer: self.layer)
        contentView.layer.addSublayer(pieLayer)
    }

    func recompute() {
        outerCircleRadius = self.bounds.size.width / 2
        innterCircleRadius = self.bounds.size.width / 6
    }
    
    func strokeChart() {
        loadDefault()
        recompute()
        
        for index in 0..<items.count {
            let currentItem = items[index]
            
            let startPercentage = startPercentageForItemAtIndex(index: index)
            let endPercentage = endPercentageForItemAtIndex(index: index)
            
            let radius = innterCircleRadius + (outerCircleRadius - innterCircleRadius) / 2
            let borderWidth = outerCircleRadius - innterCircleRadius
            
            let currentPieLayer = newCircileLayerWithRadius(radius: radius, borderWidth: borderWidth, fillColor: UIColor.clear, borderColor: currentItem.color, startPercentage: startPercentage, endPercentage: endPercentage)
            pieLayer.addSublayer(currentPieLayer)
            
        }
        
        maskChart()
        
        for index in 0..<items.count {
            let descriptionLabel = descriptionLabelForItemAtIndex(index: index)
            contentView.addSubview(descriptionLabel)
            descriptionLabels.add(descriptionLabel)
        }
        
        addAnimationIfNeeded()
    }
}

extension PNPieChart {
    func startPercentageForItemAtIndex(index: Int) -> CGFloat {
        if index == 0 {
            return 0
        } else {
            return endPercentages[index - 1]
        }
    }
    
    func endPercentageForItemAtIndex(index: Int) -> CGFloat {
        return endPercentages[index]
    }
    
    func ratioForItemAtIndex(index: Int) -> CGFloat {
        return endPercentageForItemAtIndex(index: index) - startPercentageForItemAtIndex(index: index)
    }
    
    func newCircileLayerWithRadius(radius: CGFloat, borderWidth: CGFloat, fillColor: UIColor, borderColor: UIColor, startPercentage: CGFloat, endPercentage: CGFloat) -> CAShapeLayer {
        let circle = CAShapeLayer(layer: self.layer)
        
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: -(CGFloat)(M_PI_2), endAngle: CGFloat(M_PI_2) * 3, clockwise: true)
        
        circle.fillColor = fillColor.cgColor
        circle.strokeColor = borderColor.cgColor
        circle.strokeStart = startPercentage
        circle.strokeEnd = endPercentage
        circle.lineWidth = borderWidth
        circle.path = path.cgPath
        return circle
    }
    
    func maskChart() {
        let radius = innterCircleRadius + (outerCircleRadius - innterCircleRadius) / 2
        let borderWidth = outerCircleRadius - innterCircleRadius
        let maskLayer = newCircileLayerWithRadius(radius: radius, borderWidth: borderWidth,
                                                  fillColor: UIColor.clear, borderColor: UIColor.black,
                                                  startPercentage: 0, endPercentage: 1)
        pieLayer.mask = maskLayer
    }
    
    func descriptionLabelForItemAtIndex(index: Int) -> UILabel {
        let currentDateItem = items[index]
        let distance = innterCircleRadius + (outerCircleRadius - innterCircleRadius) / 2
        let centerPercentage = (startPercentageForItemAtIndex(index: index) + endPercentageForItemAtIndex(index: index)) / 2
        let rad = Double(centerPercentage) * 2 * M_PI
        let descriptionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 80))
        let titleText = currentDateItem.text
        
        var titleValue: String {
            if showAbsoluteValues! {
                return String(format: "%.0f", currentDateItem.value)
            } else {
                return String(format: "%.0f%%", ratioForItemAtIndex(index: index) * 100)
            }
        }
        
        if hideValues! {
            descriptionLabel.text = titleText
        } else if (titleText == nil || showOnlyValues) {
            descriptionLabel.text = titleValue
        } else {
            descriptionLabel.text = titleValue + String(format: "\n%@", titleText!)
        }
        
        // If value is less than cutoff, show no label
        if ratioForItemAtIndex(index: index) < labelPercentageCutoff {
            descriptionLabel.text = nil
        }
        
        let center = CGPoint(x: outerCircleRadius + distance * CGFloat(sin(rad)),
                             y: outerCircleRadius - distance * CGFloat(cos(rad)))
    
        descriptionLabel.font = descriptionTextFont
        let labelSize = descriptionLabel.text?.size(attributes: [NSFontAttributeName: descriptionLabel.font])
        descriptionLabel.frame = CGRect(x: descriptionLabel.frame.origin.x, y: descriptionLabel.frame.origin.y, width: descriptionLabel.frame.size.width, height: (labelSize?.height)!)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = descriptionTextColor
        descriptionLabel.textAlignment = .center
        
        if showTextShadow! {
            descriptionLabel.shadowColor = descriptionTextShadowColor
            descriptionLabel.shadowOffset = descriptionTextShadowOffset
        }
        
        descriptionLabel.center = center
        descriptionLabel.alpha = 1
        descriptionLabel.backgroundColor = UIColor.clear
        return descriptionLabel
    }
    
    func addAnimationIfNeeded() {
        if displayAnimation! {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = duration
            animation.fromValue = 0
            animation.toValue = 1
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.isRemovedOnCompletion = true
            pieLayer.mask?.add(animation, forKey: "circleAnimation")
        }
    }
    
    func findPercentageOfAngleInCircle(center: CGPoint, fromPoint reference: CGPoint) -> CGFloat {
        let disY = Float(reference.y - center.y)
        let disX = Float(reference.x - center.x)
        let angleOfLine = atanf((disY) / (disX))
        let percentage = (angleOfLine + Float(M_PI_2)) / Float(2 * M_PI)
        
        if disX > 0 {
            return CGFloat(percentage)
        } else {
            return CGFloat(percentage + 0.5)
        }
    }
    
    func didTouchAt(touchLocation: CGPoint) {
        let circleCenter = CGPoint(x: contentView.bounds.size.width / 2.0, y: contentView.bounds.size.height / 2.0)
        let distanceY = Float(touchLocation.y - circleCenter.y)
        let distanceX = Float(touchLocation.x - circleCenter.x)
        let distanceFromCenter = CGFloat(sqrtf(powf(distanceY, 2.0) + powf(distanceX, 2)))
        
        if distanceFromCenter < innterCircleRadius {
            sectorHighlight.removeFromSuperlayer()
            return
        }
        
        let percentage = findPercentageOfAngleInCircle(center: circleCenter, fromPoint: touchLocation)
        var index = 0
        while percentage > endPercentageForItemAtIndex(index: index) {
            index = index + 1
        }
        
        if shouldHighlightSectorOnTouch! {
            if enableMultipleSelection! {
                if (sectorHighlight != nil) {
                    sectorHighlight.removeFromSuperlayer()
                }
                
                let currentItem = items[index]
                let newColor = currentItem.color.withAlphaComponent(1.0 / 2.0)
                let startPercentage = startPercentageForItemAtIndex(index: index)
                let endPercentage = endPercentageForItemAtIndex(index: index)
                
                sectorHighlight = newCircileLayerWithRadius(radius: outerCircleRadius + 5.0, borderWidth: 10.0, fillColor: UIColor.clear, borderColor: newColor, startPercentage: startPercentage, endPercentage: endPercentage)
                
                if enableMultipleSelection! {
                    let dicIndex = String(index)
                    let indexShape = selectedItems.value(forKey: dicIndex) as? CAShapeLayer
                    
                    if indexShape != nil {
                        indexShape?.removeFromSuperlayer()
                        selectedItems.removeObject(forKey: dicIndex)
                    } else {
                        selectedItems.setObject(sectorHighlight, forKey: dicIndex as NSCopying)
                        contentView.layer.addSublayer(sectorHighlight)
                    }
                } else {
                    contentView.layer.addSublayer(sectorHighlight)
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: contentView)
            self.didTouchAt(touchLocation: touchLocation)
        }
    }
}

