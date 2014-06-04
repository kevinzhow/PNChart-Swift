//
//  MasterViewController.swift
//  PNChart-Swift
//
//  Created by kevinzhow on 6/4/14.
//  Copyright (c) 2014 Catch Inc. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {


    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    // #pragma mark - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var viewController:UIViewController = segue.destinationViewController as UIViewController
        if segue.identifier == "lineChart" {
            //Add LineChart
            var lineChartLabel:UILabel = UILabel(frame: CGRectMake(0, 90, 320.0, 30))
            lineChartLabel.text = "Line Chart"
            lineChartLabel.textColor = PNGreenColor
            lineChartLabel.font = UIFont(name: "Avenir-Medium", size:23.0)
            lineChartLabel.textAlignment = NSTextAlignment.Center
            
            var lineChart:PNLineChart = PNLineChart(frame: CGRectMake(0, 135.0, 320, 200.0))
            lineChart.yLabelFormat = "%1.1f"
            lineChart.showLabel = true
            lineChart.backgroundColor = UIColor.clearColor()
            lineChart.xLabels = ["SEP 1","SEP 2","SEP 3","SEP 4","SEP 5","SEP 6","SEP 7"]
            lineChart.showCoordinateAxis = true
            
            // Line Chart Nr.1
            var data01Array: CGFloat[] = [60.1, 160.1, 126.4, 262.2, 186.2, 127.2, 176.2]
            var data01:PNLineChartData = PNLineChartData()
            data01.color = PNGreenColor
            data01.itemCount = data01Array.count
            data01.inflexionPointStyle = PNLineChartData.PNLineChartPointStyle.PNLineChartPointStyleCycle
            data01.getData = ({(index: Int) -> PNLineChartDataItem in
                var yValue:CGFloat = data01Array[index]
                var item = PNLineChartDataItem()
                item.y = yValue
                return item
                })
            
            lineChart.chartData = [data01]
            lineChart.strokeChart()
            
            //        lineChart.delegate = self
            
            viewController.view.addSubview(lineChart)
            viewController.view.addSubview(lineChartLabel)
        }
    }



}

