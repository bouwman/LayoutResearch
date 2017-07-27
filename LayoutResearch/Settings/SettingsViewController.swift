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
    var group: ParticipantGroup
    var rowCount: Int
    var columnCount: Int
    var itemDiameter: CGFloat
    var itemDistance: CGFloat
    var trialCount: Int
    var practiceTrialCount: Int
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
    
    var delegate: SettingsViewControllerDelegate?
    var settings: StudySettings? {
        didSet {
            updateUI()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCell = tableView.cellForRow(at: indexPath) else { return }
        
        if selectedCell == groupSelectionCell {
            toSelection()
        } else if selectedCell == resetSettingsCell {
            settings = StudySettings(group: .a, rowCount: 5, columnCount: 5, itemDiameter: 50, itemDistance: 10, trialCount: 5, practiceTrialCount: 3)
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
        
        if let settings = settings {
            delegate?.settingsViewController(viewController: self, didChangeSettings: settings)
        }
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
