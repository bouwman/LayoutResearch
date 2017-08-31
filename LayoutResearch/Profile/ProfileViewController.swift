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

class ProfileViewController: UITableViewController {
        
    let fileService = LocalDataService()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var groupLabel: UILabel!
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Large title for iOS 11
        if #available(iOS 11.0, *) {
            // TODO: Xcode 9
//            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        // Ensure the table view automatically sizes its rows.
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.white
        
        let firstName = UserDefaults.standard.string(forKey: SettingsString.participantGivenName.rawValue) ?? "Unknown"
        let lastName = UserDefaults.standard.string(forKey: SettingsString.participantFamilyName.rawValue) ?? "Name"
        
        nameLabel.text = firstName + " " + lastName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let groupStringOptional = UserDefaults.standard.string(forKey: SettingsString.participantGroup.rawValue)
        
        if let groupString = groupStringOptional, let group = ParticipantGroup(rawValue: groupString) {
            groupLabel.text = group.title
        } else {
            groupLabel.text = "Group --"
        }
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : fileService.existingResultsPaths.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Const.Identifiers.profileDataCell, for: indexPath)
        
        if indexPath.section == 0 {
            cell.textLabel?.text = "Consent Form.pdf"
        } else {
            cell.textLabel?.text = "Result \(indexPath.row + 1).csv"
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Consent file" : "Result files"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            exportConsentForm()
        } else {
            exportResult(resultNumber: indexPath.row)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.systemFont(ofSize: 23, weight: UIFontWeightBold)
        header.textLabel?.textColor = UIColor.black
        header.backgroundView?.backgroundColor = UIColor.white
        header.frame = header.frame.offsetBy(dx: 0, dy: -10) // Does not seem to work
        header.textLabel?.text = section == 0 ? "Consent file" : "Result files"
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func exportResult(resultNumber: Int) {
        guard let result = fileService.existingPathFor(resultNumber: resultNumber) else { return }
        
        present(createActivityViewControllerFor(items: [result]), animated: true, completion: nil)
    }
    
    func exportConsentForm() {
        guard fileService.isConsentAvailable else { return }
        
        present(createActivityViewControllerFor(items: [fileService.consentPath]), animated: true, completion: nil)
    }
    
    private func createActivityViewControllerFor(items: [Any]) -> UIActivityViewController {
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityVC.excludedActivityTypes = [
            .assignToContact,
            .saveToCameraRoll,
            .postToFlickr,
            .postToVimeo,
            .postToTencentWeibo,
            .postToTwitter,
            .postToFacebook,
            .openInIBooks
        ]
        return activityVC
    }
}
