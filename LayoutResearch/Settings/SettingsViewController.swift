//
//  SettingsViewController.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 27.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit
import ResearchKit

protocol SettingsViewControllerDelegate {
    func settingsViewController(viewController: SettingsViewController, didChangeSettings settings: StudySettings)
}

class SettingsViewController: UITableViewController {

    @IBOutlet weak var groupSelectionCell: UITableViewCell!
    @IBOutlet weak var resetSettingsCell: UITableViewCell!
    @IBOutlet weak var layoutPreviewCell: UITableViewCell!
    @IBOutlet weak var participantGroupLabel: UILabel!
    @IBOutlet weak var itemDiameterLabel: UILabel!
    @IBOutlet weak var itemDistanceLabel: UILabel!
    @IBOutlet weak var targetFrequencyHighCountLabel: UILabel!
    @IBOutlet weak var targetFrequencyLowCountLabel: UILabel!
    @IBOutlet weak var itemDiameterSlider: UISlider!
    @IBOutlet weak var itemDistanceSlider: UISlider!
    @IBOutlet weak var targetFrequencyHightCountSlider: UISlider!
    @IBOutlet weak var targetFrequencyLowCountSlider: UISlider!
    
    var delegate: SettingsViewControllerDelegate?
    var settings: StudySettings? {
        didSet {
            updateUI()
        }
    }
    
    var layoutPreviewView: SearchView!
    
    // MARK: - IBActions
    
    @IBAction func itemDiameterSliderChanged(_ sender: UISlider) {
        settings?.itemDiameter = CGFloat(sender.value)
        updateUI()
    }
    
    @IBAction func itemDistanceSliderChanged(_ sender: UISlider) {
        settings?.itemDistance = CGFloat(sender.value)
        updateUI()
    }
    
    @IBAction func targetFrequencyHighCountSliderChanged(_ sender: UISlider) {
        settings?.targetFreqHighCount = Int(sender.value)
        updateUI()
    }
    
    @IBAction func targetFrequencyLowCountSliderChanged(_ sender: UISlider) {
        settings?.targetFreqLowCount = Int(sender.value)
        updateUI()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCell = tableView.cellForRow(at: indexPath) else { return }
        
        if selectedCell == groupSelectionCell {
            toSelection()
        } else if selectedCell == resetSettingsCell {
            let participantOptional = UserDefaults.standard.string(forKey: SettingsString.participantIdentifier.rawValue)
            settings = StudySettings.defaultSettingsForParticipant(participantOptional!)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // MARK: Transitions
    
    func toSelection() {
        performSegue(withIdentifier: Const.Identifiers.toSelectionSegue, sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selectionVC = segue.destination as? SelectionViewController {
            selectionVC.items = allGroups
            selectionVC.delegate = self
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Fix performance issues
//        guard let settings = settings else { return }
//
//        let items = createItemsFor(rows: settings.rowCount, columns: settings.columnCount)
//
//        layoutPreviewView = SearchView(itemDiameter: settings.itemDiameter, distance: settings.itemDistance, layout: .grid, topMargin: 0, items: items)
//        
//        // TODO: Align center with autlayouts
//        // Add to center of cell
//        let width = layoutPreviewView.frame.size.width
//        let height = layoutPreviewView.frame.size.height
//        layoutPreviewView.frame.origin = CGPoint(x: layoutPreviewCell.frame.size.width / 2 - width / 2, y: layoutPreviewCell.frame.size.height / 2 - height / 2)
//        layoutPreviewCell.contentView.addSubview(layoutPreviewView)
        
        updateUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Save to userdefaults
        guard let settings = settings else { return }

        settings.saveToUserDefaults(userDefaults: UserDefaults.standard)
        
        delegate?.settingsViewController(viewController: self, didChangeSettings: settings)
    }
    
    private var allGroups: [ParticipantGroup] {
        return [.a, .b, .c, .d, .e, .f, .g, .h, .i, .j, .k, .l]
    }
    
    private func updateUI() {
        guard let settings = settings else { return }
        
        participantGroupLabel?.text = settings.group.description
        itemDiameterLabel?.text = String.localizedStringWithFormat("%.1f", settings.itemDiameter)
        itemDistanceLabel?.text = String.localizedStringWithFormat("%.1f", settings.itemDistance)
        targetFrequencyHighCountLabel?.text = "\(settings.targetFreqHighCount)"
        targetFrequencyLowCountLabel?.text = "\(settings.targetFreqLowCount)"
        
        itemDiameterSlider?.value = Float(settings.itemDiameter)
        itemDistanceSlider?.value = Float(settings.itemDistance)
        targetFrequencyHightCountSlider?.value = Float(settings.targetFreqHighCount)
        targetFrequencyLowCountSlider?.value = Float(settings.targetFreqLowCount)

        layoutPreviewView?.items = createItemsFor(rows: settings.rowCount, columns: settings.columnCount)
        layoutPreviewView?.itemDiameter = settings.itemDiameter
        layoutPreviewView?.distance = settings.itemDistance
    }
    
    private func createItemsFor(rows: Int, columns: Int) -> [[SearchItemProtocol]] {
        var items: [[SearchItemProtocol]] = []
        
        var counter = 0
        for _ in 0..<rows {
            var itemRow: [SearchItemProtocol] = []
            for _ in 0..<columns {
                itemRow.append(SearchItem(identifier: "\(counter)", colorId: 0, shapeId: 0, sharedColorCount: 0))
                counter += 1
            }
            items.append(itemRow)
        }
        
        return items
    }
    
}

extension SettingsViewController: SelectionViewControllerDelegate {
    func selectionViewController(viewController: SelectionViewController, didSelect item: SelectionPresentable) {
        if let group = item as? ParticipantGroup {
            settings?.group = group
            updateUI()
        }
    }
}
