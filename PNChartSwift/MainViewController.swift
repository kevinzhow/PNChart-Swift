//
//  MainViewController.swift
//  PNChartSwift
//
//  Created by YiChen Zhou on 8/14/17.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
		if #available(iOS 13.0, *) {
			self.view.backgroundColor = .systemBackground
		}
        self.title = "PNChart"
    }
}

extension MainViewController: UITableViewDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "chartSegue" else {
            print("Unknown segue")
            return
        }
        guard let indexPath = tableView.indexPathForSelectedRow else {
            print("Failed to get selected indexPath")
            return
        }
        let destinationVC = segue.destination as! DetailViewController
        switch indexPath.row {
        case 0:
            destinationVC.chartName = "Pie Chart"
        case 1:
            destinationVC.chartName = "Bar Chart"
        case 2:
            destinationVC.chartName = "Line Chart"
        default:
            break
        }
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chartCell", for: indexPath) as! ChartTableViewCell
        switch indexPath.row {
        case 0:
            cell.cellLabel.text = "Pie Chart"
        case 1:
            cell.cellLabel.text = "Bar Chart"
        case 2:
            cell.cellLabel.text = "Line Chart"
        default:
            break
        }
        return cell
    }
}
