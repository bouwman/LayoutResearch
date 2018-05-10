/*
Copyright (c) 2015, Apple Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1.  Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2.  Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3.  Neither the name of the copyright holder(s) nor the names of any contributors
may be used to endorse or promote products derived from this software without
specific prior written permission. No license is granted to the trademarks of
the copyright holders even if such marks are included in this software.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import UIKit
import ResearchKit

protocol AnimatableChart {
    func animateWithDuration(_ animationDuration: TimeInterval)
}

class DashboardTableViewController: UITableViewController {
    // MARK: Properties
    
    @IBOutlet var discreteGraph: ORKDiscreteGraphChartView!
    @IBOutlet var lineGraph: ORKLineGraphChartView!
    
    var allCharts: [UIView] {
        return [discreteGraph, lineGraph]
    }
    
    var service = DashboardService()
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Large title for iOS 11
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        // Set the data source for each graph
        discreteGraph.decimalPlaces = 1
        lineGraph.decimalPlaces = 1
        discreteGraph.dataSource = service.discreteGraphDataSource
        lineGraph.dataSource = service.lineGraphDataSource
        discreteGraph.noDataText = "No task results yet."
        lineGraph.noDataText = "No task results yet."
        
        // Set the table view to automatically calculate the height of cells.
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: .zero)

        // Pull to refresh
        refreshControl?.addTarget(self, action: #selector(ActivitiesViewController.handleRefresh(refreshControl:)), for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Animate any visible charts
        let visibleCells = tableView.visibleCells
        let visibleAnimatableCharts = visibleCells.compactMap { animatableChartInCell($0) }
        
        for chart in visibleAnimatableCharts {
            chart.animateWithDuration(0.5)
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Animate charts as they're scrolled into view.
        if let animatableChart = animatableChartInCell(cell) {
            animatableChart.animateWithDuration(0.5)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    // MARK: - IB actions
    
    @objc func handleRefresh(refreshControl: UIRefreshControl) {
        reloadGraphDataSources()
        // Stop after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            refreshControl.endRefreshing()
        })
    }
    
    // MARK: Convenience
    
    func reloadGraphDataSources() {
        service.reloadDataSources()
        
        discreteGraph.dataSource = service.discreteGraphDataSource
        lineGraph.dataSource = service.lineGraphDataSource
    }
    
    func animatableChartInCell(_ cell: UITableViewCell) -> AnimatableChart? {
        for chart in allCharts {
            guard let animatableChart = chart as? AnimatableChart , chart.isDescendant(of: cell) else { continue }
            return animatableChart
        }
        
        return nil
    }
}
