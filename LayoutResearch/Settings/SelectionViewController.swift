//
//  SelectionViewController.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 27.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit

protocol SelectionPresentable {
    var title: String { get }
}

protocol SelectionViewControllerDelegate {
    func selectionViewController(viewController: SelectionViewController, didSelect item: SelectionPresentable)
}

class SelectionViewController: UITableViewController {
    
    var items: [SelectionPresentable]?
    var delegate: SelectionViewControllerDelegate?

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Const.Identifiers.selectionCell, for: indexPath)
        
        cell.textLabel?.text = items![indexPath.row].title

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.popViewController(animated: true)
        delegate?.selectionViewController(viewController: self, didSelect: items![indexPath.row])
    }
}
