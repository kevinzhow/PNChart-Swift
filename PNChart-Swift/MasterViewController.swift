//
//  MasterViewController.swift
//  PNChart-Swift
//
//  Created by kevinzhow on 6/4/14.
//  Copyright (c) 2014 Catch Inc. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, PNChartDelegate {


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
        var ChartLabel:UILabel = UILabel(frame: CGRectMake(0, 90, 320.0, 30))
        
        ChartLabel.textColor = PNGreenColor
        ChartLabel.font = UIFont(name: "Avenir-Medium", size:23.0)
        ChartLabel.textAlignment = NSTextAlignment.Center
        
        switch segue.identifier as NSString {
        case "lineChart":
            //Add LineChart
            ChartLabel.text = "Line Chart"
            
            var lineChart:PNLineChart = PNLineChart(frame: CGRectMake(0, 135.0, 320, 200.0))
            lineChart.yLabelFormat = "%1.1f"
            lineChart.showLabel = true
            lineChart.backgroundColor = UIColor.clearColor()
            lineChart.xLabels = ["SEP 1","SEP 2","SEP 3","SEP 4","SEP 5","SEP 6","SEP 7"]
            lineChart.showCoordinateAxis = true
            lineChart.delegate = self
            
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
            viewController.view.addSubview(ChartLabel)
            viewController.title = "Line Chart"
        
        case "barChart":
            //Add BarChart
            ChartLabel.text = "Bar Chart"
            
            var barChart = PNBarChart(frame: CGRectMake(0, 135.0, 320.0, 200.0))
            barChart.backgroundColor = UIColor.clearColor()
            barChart.yLabelFormatter = ({(yValue: CGFloat) -> NSString in
                var yValueParsed:CGFloat = yValue
                var labelText:NSString = NSString(format:"%1.f",yValueParsed)
                return labelText;
            })
            barChart.labelMarginTop = 5.0
            barChart.xLabels = ["SEP 1","SEP 2","SEP 3","SEP 4","SEP 5","SEP 6","SEP 7"]
            barChart.yValues = [1,24,12,18,30,10,21]
            barChart.strokeChart()
            
            barChart.delegate = self
            
            viewController.view.addSubview(ChartLabel)
            viewController.view.addSubview(barChart)
            
            viewController.title = "Bar Chart"
            
        default:
            println("Hello Chart")
        }
        
    }
    
    func userClickedOnLineKeyPoint(point: CGPoint, lineIndex: Int, keyPointIndex: Int)
    {
        println("Click Key on line \(point.x), \(point.y) line index is \(lineIndex) and point index is \(keyPointIndex)")
    }
    
    func userClickedOnLinePoint(point: CGPoint, lineIndex: Int)
    {
        println("Click Key on line \(point.x), \(point.y) line index is \(lineIndex)")
    }
    
    func userClickedOnBarCharIndex(barIndex: Int)
    {
        println("Click  on bar \(barIndex)")
    }

}

