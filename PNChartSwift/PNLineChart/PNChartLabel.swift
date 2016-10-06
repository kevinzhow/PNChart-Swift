//
//  PNChartLabel.swift
//  PNChart-Swift
//
//  Created by kevinzhow on 6/4/14.
//  Copyright (c) 2014 Catch Inc. All rights reserved.
//

import UIKit

class PNChartLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        font = UIFont.boldSystemFont(ofSize: 10.0)
        textColor = PNGreyColor
        backgroundColor = UIColor.clear
        textAlignment = NSTextAlignment.center
        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
