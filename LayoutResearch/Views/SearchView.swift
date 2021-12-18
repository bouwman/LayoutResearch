//
//  SearchView.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 25.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit

enum LayoutType {
    case horizontal, vertical, grid
}

protocol SearchItemProtocol {
    var identifier: String { set get }
    var colorId: Int { get }
    var shapeId: Int { get }
    var sharedColorCount: Int { get }
}

protocol SearchViewDelegate {
    func didSelect(item: SearchItemProtocol?, atIndex index: IndexPath?)
}

class SearchView: UIView {
    var itemDiameter: CGFloat {
        didSet {
            layoutButtons()
        }
    }
    var distance: CGFloat {
        didSet {
            if distance <= 0 {
                distance = 0.001
            }
            layoutButtons()
        }
    }
    var layout: LayoutType {
        didSet {
            layoutButtons()
        }
    }
    var items: [[SearchItemProtocol]] {
        didSet {
            createButtonsForItems()
            layoutButtons()
        }
    }
    var topMargin: CGFloat {
        didSet {
            layoutButtons()
        }
    }
    
    var layoutIdForIB: Int = 1 {
        didSet {
            switch layoutIdForIB {
            case 1:
                layout = .grid
            case 2:
                layout = .horizontal
            case 3:
                layout = .vertical
            default:
                layoutIdForIB = 1
                layout = .grid
            }
        }
    }
    
    var delegate: SearchViewDelegate?
    
    private var buttons: [[RoundedButton]] = []
    
    override var intrinsicContentSize: CGSize {
        let lastXButton: UIButton
        var lastYButton = buttons.last!.last!
        if buttons.count % 2 == 1 {
            lastXButton = buttons.last!.last!
        } else {
            lastXButton = buttons[buttons.count - 2].last!
        }
        if layout == .vertical {
            lastYButton = buttons.last!.first!
        }
        let width = lastXButton.frame.origin.x + itemDiameter
        let height = lastYButton.frame.origin.y + itemDiameter
        
        return CGSize(width: width, height: height)
    }
    
    init(itemDiameter: CGFloat, distance: CGFloat, layout: LayoutType, topMargin: CGFloat, items: [[SearchItemProtocol]]) {
        self.itemDiameter = itemDiameter
        self.distance = distance
        self.layout = layout
        self.topMargin = topMargin
        self.items = items
        
        super.init(frame: CGRect.zero)
        
        // Map buttons to items
        createButtonsForItems()
        
        // Layout buttons
        layoutButtons()
        
        // Set frame based on layout
        frame = CGRect(x: 0, y: 0, width: intrinsicContentSize.width, height: intrinsicContentSize.height)
    }    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didPress(button: RoundedButton) {
        guard let delegate = delegate else { return }
        
        var index: IndexPath?
        var item: SearchItemProtocol?
        
        for (row, itemsInRow) in items.enumerated() {
            if let column = itemsInRow.firstIndex(where: { $0.identifier == button.identifier }) {
                item = itemsInRow[column]
                index = IndexPath(row: row, section: column)
            }
        }
        
        delegate.didSelect(item: item, atIndex: index)
    }
    
    private func createButtonsForItems() {
        // Remove buttons if exist
        if buttons.count > 0 {
            for buttonRow in buttons {
                for button in buttonRow {
                    button.removeTarget(self, action: #selector(didPress(button:)), for: .touchDown)
                    button.removeFromSuperview()
                }
            }
            buttons.removeAll()
        }
        
        // Map buttons to items
        for itemsInRow in items {
            var buttonRow: [RoundedButton] = []
            for item in itemsInRow {
                let button = RoundedButton(frame: CGRect(x: 0, y: 0, width: itemDiameter, height: itemDiameter))
                let inset = itemDiameter / Const.Interface.iconInsetDiameterRatio
                
                button.identifier = item.identifier
                button.backgroundColor = UIColor.searchColorFor(id: item.colorId)
                button.setImage(UIImage.searchImageFor(id: item.shapeId), for: .normal)
                button.imageView?.contentMode = .scaleAspectFit
                button.imageEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
                button.addTarget(self, action: #selector(SearchView.didPress(button:)), for: .touchDown)
                
                addSubview(button)
                buttonRow.append(button)
            }
            buttons.append(buttonRow)
        }
    }
    
    private func layoutButtons() {
        guard layout != .grid else {
            for (row, itemsInRow) in items.enumerated() {
                for (column, _) in itemsInRow.enumerated() {
                    let button = buttons[row][column]
                    button.frame.origin.x = CGFloat(column) * (distance + itemDiameter)
                    button.frame.origin.y = topMargin + CGFloat(row) * (distance + itemDiameter)
                }
            }
            return
        }
        
        let offset: CGFloat = itemDiameter + distance
        let xOffset: CGFloat
        let yOffset: CGFloat
        
        if layout == .vertical {
            xOffset = cos(30 * CGFloat.pi / 180) * offset
            yOffset = sin(150 * CGFloat.pi / 180) * offset
        } else {
            xOffset = sin(30 * CGFloat.pi / 180) * offset
            yOffset = -cos(150 * CGFloat.pi / 180) * offset
        }
        
        for (row, itemsInRow) in items.enumerated() {
            for (column, _) in itemsInRow.enumerated() {
                let button = buttons[row][column]
                
                if layout == .vertical {
                    let unevenColumn = Double(column).truncatingRemainder(dividingBy: 2)
                    let xPosition = CGFloat(column) * xOffset
                    let yPosition = topMargin + CGFloat(row) * offset
                    // For all even columns (2, 4, ...)
                    if unevenColumn == 0 {
                        button.frame.origin.y = yPosition + yOffset
                    } else { // For all uneven columns (1, 3, ...)
                        button.frame.origin.y = yPosition
                    }
                    button.frame.origin.x = xPosition
                } else {
                    let unevenRow = Double(row).truncatingRemainder(dividingBy: 2)
                    let xPosition = CGFloat(column) * offset
                    let yPosition = topMargin + CGFloat(row) * yOffset
                    
                    // For all even rows (2, 4, ...)
                    if unevenRow == 0 {
                        button.frame.origin.x = xPosition + xOffset
                    } else { // For all uneven rows (1, 3, ...)
                        button.frame.origin.x = xPosition
                    }
                    button.frame.origin.y = yPosition
                }
            }
        }        
    }
    
    static func createDefaultItems() -> [[SearchItemProtocol]] {
        var items: [[SearchItemProtocol]] = []
        
        var counter = 1
        for _ in 0..<5 {
            var rowItems: [SearchItemProtocol] = []
            for _ in 0..<5 {
                // 0 for black color and no shape
                let item = SearchItem(identifier: "\(counter)", colorId: 0, shapeId: 0, sharedColorCount: 0)
                rowItems.append(item)
                counter += 1
            }
            items.append(rowItems)
        }
        return items
    }
}

