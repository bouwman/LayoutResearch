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

import ResearchKit

class DiscreteGraphDataSource: NSObject, ORKValueRangeGraphChartViewDataSource {
    // MARK: Properties
    
    private var plotPoints: [[ORKValueRange]] {
        if let dataPoints = dataPoints {
            return dataPoints
        } else {
            // Return empty array
            var points: [[ORKValueRange]] = []
            let data: [ORKValueRange] = []
            points.append(data)
            return points
            // return dummyPoints
        }
    }
    
    var dataPoints: [[ORKValueRange]]?
    
    init(dataPoints: [[ORKValueRange]]? = nil) {
        self.dataPoints = dataPoints
    }
    
    
    // MARK: ORKGraphChartViewDataSource
    
    func numberOfPlots(in graphChartView: ORKGraphChartView) -> Int {
        return plotPoints.count
    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, dataPointForPointIndex pointIndex: Int, plotIndex: Int) -> ORKValueRange {
        return plotPoints[plotIndex][pointIndex]
    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, numberOfDataPointsForPlotIndex plotIndex: Int) -> Int {
        return plotPoints[plotIndex].count
    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, titleForXAxisAtPointIndex pointIndex: Int) -> String? {
        return "Day \(pointIndex + 1)"
    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, colorForPlotIndex plotIndex: Int) -> UIColor {
        switch plotIndex {
        case 0:
            return UIColor(red: 90, green: 200, blue: 250)
        case 1:
            return UIColor(red: 0, green: 122, blue: 255)
        case 2:
            return UIColor(red: 88, green: 86, blue: 214)
        default:
            return UIColor.lightGray
        }
    }
    
    // MARK: - Helper
    
    private var dummyPoints =
        [
            [
                ORKValueRange(minimumValue: 0, maximumValue: 2),
                ORKValueRange(minimumValue: 0, maximumValue: 4),
                ORKValueRange(minimumValue: 0, maximumValue: 6),
                ORKValueRange(minimumValue: 0, maximumValue: 2),
                ORKValueRange(minimumValue: 0, maximumValue: 6)
                ],
            [
                ORKValueRange(minimumValue: 0, maximumValue: 3),
                ORKValueRange(minimumValue: 0, maximumValue: 3),
                ORKValueRange(minimumValue: 0, maximumValue: 4),
                ORKValueRange(minimumValue: 0, maximumValue: 3),
                ORKValueRange(minimumValue: 0, maximumValue: 5)
                ],
            [
                ORKValueRange(minimumValue: 0, maximumValue: 4),
                ORKValueRange(minimumValue: 0, maximumValue: 2),
                ORKValueRange(minimumValue: 0, maximumValue: 5),
                ORKValueRange(minimumValue: 0, maximumValue: 4),
                ORKValueRange(minimumValue: 0, maximumValue: 6)
                ]
    ]
}
