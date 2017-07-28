//
//  SettingsViewController.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 27.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit
import ResearchKit

enum ParticipantGroup: String, CustomStringConvertible, SelectionPresentable {
    case a,b,c,d,e,f,g,h,i,j,k,l
    
    var layouts: [LayoutType] {
        switch self {
        case .a,.g:
            return [.grid, .horizontal, .vertical]
        case .b,.h:
            return [.grid, .vertical, .horizontal]
        case .c,.i:
            return [.horizontal, .grid, .vertical]
        case .d,.j:
            return [.vertical, .grid, .horizontal]
        case .e,.k:
            return [.vertical, .horizontal, .grid]
        case .f,.l:
            return [.horizontal, .vertical, .grid]
        }
    }
    
    var organisation: OrganisationType {
        switch self {
        case .a,.b,.c,.d,.e,.f:
            return .stable
        case .g,.h,.i,.j,.k,.l:
            return .random
        }
    }
    
    var description: String {
        return "Group \(self.rawValue.uppercased())"
    }
    
    var title: String {
        return description
    }
}

struct StudySettings {
    var participant: String
    var group: ParticipantGroup
    var rowCount: Int
    var columnCount: Int
    var itemDiameter: CGFloat
    var itemDistance: CGFloat
    var trialCount: Int
    var practiceTrialCount: Int
    
    func saveToUserDefaults(userDefaults: UserDefaults) {
        userDefaults.set(participant, forKey: SettingsString.participantIdentifier.rawValue)
        userDefaults.set(group.rawValue, forKey: SettingsString.participantGroup.rawValue)
        userDefaults.set(itemDiameter, forKey: SettingsString.layoutItemDiameter.rawValue)
        userDefaults.set(itemDistance, forKey: SettingsString.layoutItemDistance.rawValue)
        userDefaults.set(rowCount, forKey: SettingsString.layoutRowCount.rawValue)
        userDefaults.set(columnCount, forKey: SettingsString.layoutColumnCount.rawValue)
        userDefaults.set(trialCount, forKey: SettingsString.trialCount.rawValue)
        userDefaults.set(practiceTrialCount, forKey: SettingsString.practiceTrialCount.rawValue)
    }
    
    static func fromUserDefaults(userDefaults: UserDefaults) -> StudySettings? {
        let participantOptional = userDefaults.string(forKey: SettingsString.participantIdentifier.rawValue)
        let groupStringOptional = userDefaults.string(forKey: SettingsString.participantGroup.rawValue)
        let rowCount = userDefaults.integer(forKey: SettingsString.layoutRowCount.rawValue)
        let columnCount = userDefaults.integer(forKey: SettingsString.layoutColumnCount.rawValue)
        let itemDiameter = userDefaults.float(forKey: SettingsString.layoutItemDiameter.rawValue)
        let itemDistance = userDefaults.float(forKey: SettingsString.layoutItemDistance.rawValue)
        let trialCount = userDefaults.integer(forKey: SettingsString.trialCount.rawValue)
        let practiceTrialCount = userDefaults.integer(forKey: SettingsString.practiceTrialCount.rawValue)
        
        guard let groupString = groupStringOptional else { return nil }
        guard let group = ParticipantGroup(rawValue: groupString) else { return nil }
        guard let participant = participantOptional else { return nil }
        
        return StudySettings(participant: participant, group: group, rowCount: rowCount, columnCount: columnCount, itemDiameter: CGFloat(itemDiameter), itemDistance: CGFloat(itemDistance), trialCount: trialCount, practiceTrialCount: practiceTrialCount)
    }
}

protocol SettingsViewControllerDelegate {
    func settingsViewController(viewController: SettingsViewController, didChangeSettings settings: StudySettings)
}

class SettingsViewController: UITableViewController {

    @IBOutlet weak var groupSelectionCell: UITableViewCell!
    @IBOutlet weak var resetSettingsCell: UITableViewCell!
    @IBOutlet weak var participantGroupLabel: UILabel!
    @IBOutlet weak var itemDiameterLabel: UILabel!
    @IBOutlet weak var itemDistanceLabel: UILabel!
    @IBOutlet weak var rowCountLabel: UILabel!
    @IBOutlet weak var columnCountLabel: UILabel!
    @IBOutlet weak var itemDiameterSlider: UISlider!
    @IBOutlet weak var itemDistanceSlider: UISlider!
    @IBOutlet weak var rowCountSlider: UISlider!
    @IBOutlet weak var columnCountSlider: UISlider!
    
    var delegate: SettingsViewControllerDelegate?
    var settings: StudySettings? {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func itemDiameterSliderChanged(_ sender: UISlider) {
        settings?.itemDiameter = CGFloat(sender.value)
        updateUI()
    }
    
    @IBAction func itemDistanceSliderChanged(_ sender: UISlider) {
        settings?.itemDistance = CGFloat(sender.value)
        updateUI()
    }
    
    @IBAction func rowCountSliderChanged(_ sender: UISlider) {
        settings?.rowCount = Int(sender.value)
        updateUI()
    }
    
    @IBAction func columnCountSliderChanged(_ sender: UISlider) {
        settings?.columnCount = Int(sender.value)
        updateUI()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCell = tableView.cellForRow(at: indexPath) else { return }
        
        if selectedCell == groupSelectionCell {
            toSelection()
        } else if selectedCell == resetSettingsCell {
            let participantOptional = UserDefaults.standard.string(forKey: SettingsString.participantIdentifier.rawValue)
            settings = StudySettings(participant: participantOptional!, group: Const.StudyParameters.group, rowCount: Const.StudyParameters.rowCount, columnCount: Const.StudyParameters.columnCount, itemDiameter: Const.StudyParameters.itemDiameter, itemDistance: Const.StudyParameters.itemDistance, trialCount: Const.StudyParameters.trialCount, practiceTrialCount: Const.StudyParameters.practiceTrialCount)
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
        itemDiameterLabel?.text = "\(Int(settings.itemDiameter))"
        itemDistanceLabel?.text = "\(Int(settings.itemDistance))"
        rowCountLabel?.text = "\(settings.rowCount)"
        columnCountLabel?.text = "\(settings.columnCount)"
        
        itemDiameterSlider?.value = Float(settings.itemDiameter)
        itemDistanceSlider?.value = Float(settings.itemDistance)
        rowCountSlider?.value = Float(settings.rowCount)
        columnCountSlider?.value = Float(settings.columnCount)
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
