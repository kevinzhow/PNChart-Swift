//
//  ViewController.swift
//  PNChartSwift
//
//  Created by YiChen Zhou on 12/30/16.
//
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let item1 = PNPieChartDataItem(dateValue: 20, dateColor:  PNLightGreen, description: "Build")
        let item2 = PNPieChartDataItem(dateValue: 20, dateColor: PNFreshGreen, description: "I/O")
        let item3 = PNPieChartDataItem(dateValue: 45, dateColor: PNDeepGreen, description: "WWDC")
        
        let frame = CGRect(x: 40.0, y: 155.0, width: 240.0, height: 240.0)
        let items: [PNPieChartDataItem] = [item1, item2, item3]
        let pieChart = PNPieChart(frame: frame, items: items)
        pieChart.descriptionTextColor = UIColor.white
        pieChart.descriptionTextFont = UIFont(name: "Avenir-Medium", size: 14.0)!
        pieChart.center = self.view.center
        
        let barChart = PNBarChart(frame: CGRect(x: 0.0, y: 135.0, width: 320.0, height: 200.0))
        barChart.backgroundColor = UIColor.clear
        barChart.animationType = .Waterfall
        barChart.labelMarginTop = 5.0
        barChart.xLabels = ["Sep 1", "Sep 2", "Sep 3", "Sep 4", "Sep 5", "Sep 6", "Sep 7"]
        barChart.yValues = [1, 23, 12, 18, 30, 12, 21]
        barChart.strokeChart()
        barChart.center = self.view.center
        
        let lineChart = PNLineChart(frame: CGRect(x: 0.0, y: 135.0, width: 320.0, height: 250.0))
        lineChart.yLabelFormat = "%1.1f"
        lineChart.showLabel = true
        lineChart.backgroundColor = UIColor.clear
        lineChart.xLabels = ["Sep 1", "Sep 2", "Sep 3", "Sep 4", "Sep 5", "Sep 6", "Sep 7"]
        lineChart.showCoordinateAxis = true
        lineChart.center = self.view.center
        
        let dataArr = [60.1, 160.1, 126.4, 232.2, 186.2, 127.2, 176.2]
        let data = PNLineChartData()
        data.color = PNGreen
        data.itemCount = dataArr.count
        data.inflexPointStyle = .None
        data.getData = ({
            (index: Int) -> PNLineChartDataItem in
            let yValue = CGFloat(dataArr[index])
            let item = PNLineChartDataItem(y: yValue)
            return item
        })
        
        lineChart.chartData = [data]
        lineChart.strokeChart()
        
        // Change the chart you want to present here
        self.view.addSubview(pieChart)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

