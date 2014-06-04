//
//  PNChartLabel.swift
//  PNChart-Swift
//
//  Created by kevinzhow on 6/4/14.
//  Copyright (c) 2014 Catch Inc. All rights reserved.
//

import UIKit

class PNChartLabel: UILabel {
    
    init(frame: CGRect) {
        super.init(frame: frame)
        self.font = UIFont.boldSystemFontOfSize(10.0)
        self.textColor = PNGrey
        self.backgroundColor = UIColor.clearColor()
        self.textAlignment = NSTextAlignment.Center
        self.userInteractionEnabled = true
    }

}
