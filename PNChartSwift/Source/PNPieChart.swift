//
//  PNPieChart.swift
//  PNChartSwift
//
//  Created by YiChen Zhou on 12/27/16.
//  Copyright © 2016 YiChen Zhou. All rights reserved.
//

import UIKit

class PNPieChart: PNGenericChart {
    lazy var items: [PNPieChartDataItem] = {
        return [PNPieChartDataItem]()
    }()
    
    var endPercentages = [CGFloat]()
    var contentView = UIView()
    var pieLayer: CAShapeLayer = {
        return CAShapeLayer()
    }()
    
    var descriptionLabels = NSMutableArray()
    var sectorHighlight: CAShapeLayer = {
        return CAShapeLayer()
    }()
    
    var selectedItems = NSMutableDictionary()
    var descriptionTextFont: UIFont = {
        return UIFont(name: "Avenir-Medium", size: 14)!
    }()
    var descriptionTextColor: UIColor = {
        return UIColor.white
    }()
    var descriptionTextShadowColor: UIColor = {
        return UIColor.darkGray
    }()
    var descriptionTextShadowOffset: CGSize = {
        return CGSize(width: 0, height: 1)
    }()
    var duration: TimeInterval = 1.0
    
    var hideValues: Bool = true
    var showOnlyValues: Bool = true
    var showAbsoluteValues: Bool = true
    var showTextShadow: Bool = true
    
    // Hide percentage labels less than cutoff value
    var labelPercentageCutoff: CGFloat = 0
    
    // Default as true
    var shouldHighlightSectorOnTouch: Bool = true
    
    // Current outer radius. Override recompute() to change this.
    lazy var outerCircleRadius: CGFloat = {
        return self.bounds.size.width / 2
    }()
    
    // Current inner radius. Override recompute() to change this.
    lazy var innerCircleRadius: CGFloat = {
        return self.bounds.size.width / 6
    }()
    
    // Multiple selection
    var enableMultipleSelection: Bool = true
    
    init(frame: CGRect, items: [PNPieChartDataItem]) {
        super.init(frame: frame)
        self.items = items
        self.baseInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.baseInit()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.strokeChart()
    }
    
    func baseInit() {
        self.shouldHighlightSectorOnTouch = true
        self.enableMultipleSelection = true
        self.labelPercentageCutoff = 0
        self.hideValues = false
        self.showOnlyValues = false
        self.showAbsoluteValues = false
        self.showTextShadow = false
        super.setupDefaultValues()
        self.loadDefault()
    }
    
    func loadDefault() {
        var currentTotal: CGFloat = 0;
        var total: CGFloat = 0
        for index in 0..<self.items.count {
            total = total + self.items[index].value!
        }
        
        for index in 0..<self.items.count {
            if total == 0 {
                self.endPercentages.append(CGFloat(1/(self.items.count * (index + 1))))
            } else {
                currentTotal = currentTotal + self.items[index].value!
                self.endPercentages.append(currentTotal / total)
            }
        }
        
        self.contentView.removeFromSuperview()
        self.contentView = UIView(frame: self.bounds)
        self.addSubview(self.contentView)
        self.pieLayer = CAShapeLayer(layer: self.layer)
        self.contentView.layer.addSublayer(self.pieLayer)
    }

    func recompute() {
        self.outerCircleRadius = self.bounds.size.width / 2
        self.innerCircleRadius = self.bounds.size.width / 6
    }
    
    func strokeChart() {
        self.loadDefault()
        self.recompute()
        for index in 0..<self.items.count {
            let currentItem = self.items[index]
            let startPercentage = self.startPercentageForItemAtIndex(index: index)
            let endPercentage = self.endPercentageForItemAtIndex(index: index)
            let radius = self.innerCircleRadius + (self.outerCircleRadius - self.innerCircleRadius) / 2
            let borderWidth = self.outerCircleRadius - self.innerCircleRadius
            let currentPieLayer = self.newCircileLayerWithRadius(radius: radius, borderWidth: borderWidth, fillColor: UIColor.clear, borderColor: currentItem.color!, startPercentage: startPercentage, endPercentage: endPercentage)
            self.pieLayer.addSublayer(currentPieLayer)
        }
        
        self.maskChart()
        
        for index in 0..<self.items.count {
            guard let descriptionLabel = self.descriptionLabelForItemAtIndex(index: index) else {
                print("Variable description is nil")
                return
            }
            self.contentView.addSubview(descriptionLabel)
            self.descriptionLabels.add(descriptionLabel)
        }
        
        self.addAnimationIfNeeded()
    }
}

extension PNPieChart {
    func startPercentageForItemAtIndex(index: Int) -> CGFloat {
        if index == 0 {
            return 0
        } else {
            return self.endPercentages[index - 1]
        }
    }
    
    func endPercentageForItemAtIndex(index: Int) -> CGFloat {
        return self.endPercentages[index]
    }
    
    func ratioForItemAtIndex(index: Int) -> CGFloat {
        return self.endPercentageForItemAtIndex(index: index) - self.startPercentageForItemAtIndex(index: index)
    }
    
    func newCircileLayerWithRadius(radius: CGFloat, borderWidth: CGFloat, fillColor: UIColor, borderColor: UIColor, startPercentage: CGFloat, endPercentage: CGFloat) -> CAShapeLayer {
        let circle = CAShapeLayer(layer: self.layer)
        
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: -(CGFloat)(Double.pi/2), endAngle: CGFloat(Double.pi/2) * 3, clockwise: true)
        circle.fillColor = fillColor.cgColor
        circle.strokeColor = borderColor.cgColor
        circle.strokeStart = startPercentage
        circle.strokeEnd = endPercentage
        circle.lineWidth = borderWidth
        circle.path = path.cgPath
        return circle
    }
    
    func maskChart() {
        let radius = self.innerCircleRadius + (self.outerCircleRadius - self.innerCircleRadius) / 2
        let borderWidth = self.outerCircleRadius - self.innerCircleRadius
        let maskLayer = self.newCircileLayerWithRadius(radius: radius, borderWidth: borderWidth, fillColor: UIColor.clear, borderColor: UIColor.black, startPercentage: 0, endPercentage: 1)
        self.pieLayer.mask = maskLayer
    }
    
    func descriptionLabelForItemAtIndex(index: Int) -> UILabel? {
        let currentDateItem = self.items[index]
        let distance = self.innerCircleRadius + (self.outerCircleRadius - self.innerCircleRadius) / 2
        let centerPercentage = (self.startPercentageForItemAtIndex(index: index) + self.endPercentageForItemAtIndex(index: index)) / 2
        let rad = Double(centerPercentage) * 2 * Double.pi
        let descriptionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 80))
        let titleText = currentDateItem.text
        var titleValue: String {
            if self.showAbsoluteValues {
                return String(format: "%.0f", currentDateItem.value!)
            } else {
                return String(format: "%.0f%%", self.ratioForItemAtIndex(index: index) * 100)
            }
        }
        
        if self.hideValues {
            descriptionLabel.text = titleText
        } else if (titleText == nil || self.showOnlyValues) {
            descriptionLabel.text = titleValue
        } else {
            descriptionLabel.text = titleValue + String(format: "\n%@", titleText!)
        }
        
        // If value is less than cutoff, show no label
        if self.ratioForItemAtIndex(index: index) < self.labelPercentageCutoff {
            descriptionLabel.text = nil
        }
        
        let center = CGPoint(x: self.outerCircleRadius + distance * CGFloat(sin(rad)), y: self.outerCircleRadius - distance * CGFloat(cos(rad)))
        descriptionLabel.font = self.descriptionTextFont
		let labelSize = descriptionLabel.text?.size(withAttributes: [NSAttributedString.Key.font: descriptionLabel.font as Any])
        descriptionLabel.frame = CGRect(x: descriptionLabel.frame.origin.x, y: descriptionLabel.frame.origin.y, width: descriptionLabel.frame.size.width, height: (labelSize?.height)!)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = self.descriptionTextColor
        descriptionLabel.textAlignment = .center
        
        if self.showTextShadow {
            descriptionLabel.shadowColor = self.descriptionTextShadowColor
            descriptionLabel.shadowOffset = self.descriptionTextShadowOffset
        }
        
        descriptionLabel.center = center
        descriptionLabel.alpha = 1
        descriptionLabel.backgroundColor = UIColor.clear
        return descriptionLabel
    }
    
    func addAnimationIfNeeded() {
        if self.displayAnimation {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = duration
            animation.fromValue = 0
            animation.toValue = 1
			animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            animation.isRemovedOnCompletion = true
            self.pieLayer.mask?.add(animation, forKey: "circleAnimation")
        }
    }
    
    func findPercentageOfAngleInCircle(center: CGPoint, fromPoint reference: CGPoint) -> CGFloat {
        let disY = Float(reference.y - center.y)
        let disX = Float(reference.x - center.x)
        let angleOfLine = atanf((disY) / (disX))
        let percentage = (angleOfLine + Float(Double.pi/2)) / Float(2 * Double.pi)
        
        if disX > 0 {
            return CGFloat(percentage)
        } else {
            return CGFloat(percentage + 0.5)
        }
    }
    
    func didTouchAt(touchLocation: CGPoint) {
        let circleCenter = CGPoint(x: self.contentView.bounds.size.width / 2.0, y: self.contentView.bounds.size.height / 2.0)
        let distanceY = Float(touchLocation.y - circleCenter.y)
        let distanceX = Float(touchLocation.x - circleCenter.x)
        let distanceFromCenter = CGFloat(sqrtf(powf(distanceY, 2) + powf(distanceX, 2)))
        
        if distanceFromCenter < self.innerCircleRadius {
            self.sectorHighlight.removeFromSuperlayer()
            return
        }
        
        let percentage = self.findPercentageOfAngleInCircle(center: circleCenter, fromPoint: touchLocation)
        var index = 0
        while percentage > self.endPercentageForItemAtIndex(index: index) {
            index = index + 1
        }
        
        if self.shouldHighlightSectorOnTouch {
            if self.enableMultipleSelection {
                self.sectorHighlight.removeFromSuperlayer()
                let currentItem = self.items[index]
                let newColor = currentItem.color!.withAlphaComponent(0.5)
                let startPercentage = self.startPercentageForItemAtIndex(index: index)
                let endPercentage = self.endPercentageForItemAtIndex(index: index)
                
                self.sectorHighlight = self.newCircileLayerWithRadius(radius: outerCircleRadius + 5, borderWidth: 10, fillColor: UIColor.clear, borderColor: newColor, startPercentage: startPercentage, endPercentage: endPercentage)
                if self.enableMultipleSelection {
                    let dicIndex = String(index)
                    let indexShape = self.selectedItems.value(forKey: dicIndex) as? CAShapeLayer
                    
                    if indexShape != nil {
                        indexShape?.removeFromSuperlayer()
                        self.selectedItems.removeObject(forKey: dicIndex)
                    } else {
                        self.selectedItems.setObject(self.sectorHighlight, forKey: dicIndex as NSCopying)
                        self.contentView.layer.addSublayer(self.sectorHighlight)
                    }
                } else {
                    self.contentView.layer.addSublayer(self.sectorHighlight)
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self.contentView)
            self.didTouchAt(touchLocation: touchLocation)
        }
    }
}

