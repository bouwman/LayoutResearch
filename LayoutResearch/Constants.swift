//
//  Constants.swift
//  LayoutResearch
//
//  Created by Tassilo Bouwman on 24.07.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import UIKit

struct Const {
    struct Identifiers {
        static let consetReviewStep = "ConsentReviewStep"
        static let visualConsentStep = "VisualConsentStep"
        static let selectionCell = "SelectionCell"
        static let toSelectionSegue = "toSelection"
    }
    struct Interface {
        static let insetDiameterRatio: CGFloat = 4.1
        static let descriptionItemMargin: CGFloat = 50
        static let searchLayoutMargin: CGFloat = 200
        static let introLayoutMargin: CGFloat = 30
        static let shapeCount: Int = 27
    }
    struct StudyParameters {
        static let group: ParticipantGroup = .a
        static let rowCount = 5
        static let columnCount = 5
        static let itemDiameter: CGFloat = 50.0
        static let itemDistance: CGFloat = 10.0
        static let trialCount = 3
        static let practiceTrialCount = 3
    }
}

enum SettingsString: String {
    case isParticipating
    case consentPath
    case resultCSVPath
    case participantIdentifier
    case participantGroup
    case layoutItemDiameter
    case layoutItemDistance
    case layoutRowCount
    case layoutColumnCount
    case trialCount
    case practiceTrialCount
}

extension UIColor {
    static func searchColorFor(id: Int) -> UIColor {
        if #available(iOS 11.0, *) {
            return UIColor(named: "Color\(id)") ?? UIColor.black
        } else {
            switch id {
            case 0:
                return UIColor.black
            case 1:
                return UIColor(rgbHex: 0x70C3ED)
            case 2:
                return UIColor(rgbHex: 0xFDB64E)
            case 3:
                return UIColor(rgbHex: 0x879BCE)
            case 4:
                return UIColor(rgbHex: 0xF05F90)
            case 5:
                return UIColor(rgbHex: 0xAED361)
            case 6:
                return UIColor(rgbHex: 0x8ECFB5)
            case 7:
                return UIColor(rgbHex: 0xF15C40)
            default:
                return UIColor.gray
            }
        }
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        if #available(iOS 10.0, *) {
            self.init(displayP3Red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
        } else {
            self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
        }
    }
    
    convenience init(rgbHex: Int) {
        self.init(
            red: (rgbHex >> 16) & 0xFF,
            green: (rgbHex >> 8) & 0xFF,
            blue: rgbHex & 0xFF
        )
    }
}

extension UIImage {
    static func searchImageFor(id: Int) -> UIImage? {
        return UIImage(named: "Shape\(id)")
    }
}

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}