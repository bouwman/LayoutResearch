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
        static let eligibilityStep = "EligibilityStep"
        static let eligibilityItemAge = "EligibilityItemAge"
        static let eligibilityItemGender = "EligibilityItemGender"
        static let visualConsentStep = "VisualConsentStep"
        static let layoutSurveyStep = "LayoutSurveyStep"
        static let densitySurveyStep = "DensitySurveyStep"
        static let selectionCell = "SelectionCell"
        static let profileDataCell = "ProfileDataCell"
        static let activityCell = "ActivityCell"
        static let toSelectionSegue = "toSelection"
    }
    struct Interface {
        static let iconInsetDiameterRatio: CGFloat = 3.8
        static let descriptionItemMargin: CGFloat = 50
        static let searchLayoutMargin: CGFloat = 50
        static let introLayoutMargin: CGFloat = 0
        static let shapeCount: Int = 27
        static let graphOffset: Double = 0.2
    }
    struct StudyParameters {
        static let rowCount = 6
        static let columnCount = 4
        static let itemDiameter: CGFloat = 55.0
        static let practiceTrialCount = 3
        static let targetFreqLowCount = 2
        static let targetFreqHighCount = 6
        static let distractorColorLowCount = 2
        static let distractorColorHighCount = 6
        static let colorIdFarApartCondition1 = 5
        static let colorIdFarApartCondition2 = 6
        static let colorIdApartCondition = 2
        static let itemDistanceApartCondition = 1
        static let itemDistanceFurtherApartCondition = 2...3
        static let searchActivityCount = 3
    }
}

enum SettingsString: String {
    case versionOfLastRun
    case isParticipating
    case consentPath
    case searchResultWasUploaded
    case surveyResultWasUploaded
    case participantsEmailWasUploaded
    case lastActivityCompletionDate
    case lastActivityNumber
    case isParticipantGroupAssigned
    case preferredLayout
    case preferredDensity
    case participantGivenName
    case participantFamilyName
    case participantEmail
    case participantAge
    case participantGender
    case icloudUserId
    case participantIdentifier
    case participantGroup
    case layoutItemDiameter
    case layoutRowCount
    case layoutColumnCount
    case practiceTrialCount
    case targetFreqLowCount
    case targetFreqHighCount
    case distractorColorLowCount
    case distractorColorHighCount
    case avgTimeHorResult
    case avgTimeVerResult
    case avgTimeGridResult
    case lastUsedShapeIDs
    case lastUsedSearchItems
}

extension UIColor {
    static func globalTint() -> UIColor {
        return UIColor(rgbHex: 0xFF2D55)
    }
    
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

// Swift 3
extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            self.swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

// Swift 4
//extension MutableCollection {
//    /// Shuffles the contents of this collection.
//    mutating func shuffle() {
//        let c = count
//        guard c > 1 else { return }
//        
//        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
//            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
//            let i = index(firstUnshuffled, offsetBy: d)
//            swapAt(firstUnshuffled, i)
//        }
//    }
//}
//
//extension Sequence {
//    /// Returns an array with the contents of this sequence, shuffled.
//    func shuffled() -> [Element] {
//        var result = Array(self)
//        result.shuffle()
//        return result
//    }
//}

func -(left: IndexPath, right: IndexPath) -> IndexPath {
    return IndexPath(row: left.row - right.row, section: left.section - right.section)
}

func randomInt(min: Int, max:Int) -> Int {
    return min + Int(arc4random_uniform(UInt32(max - min + 1)))
}

enum ItemDistance {
    case standard
    case standardEqualWhiteSpace
    case fix(CGFloat)
    case fixEqualWhiteSpace(CGFloat)
}

func itemDistanceWithEqualWhiteSpaceFor(layout: LayoutType, itemDiameter: CGFloat, itemDistance: ItemDistance) -> CGFloat {
    let itemDistanceValue: CGFloat
    switch itemDistance {
    case .standard:
        itemDistanceValue = 16/60 * itemDiameter
        // Return without calculating equal white space
        return itemDistanceValue
    case .standardEqualWhiteSpace:
        itemDistanceValue = 16/60 * itemDiameter
    case .fix(let value):
        itemDistanceValue = value
        // Return without calculating equal white space
        return itemDistanceValue
    case .fixEqualWhiteSpace(let value):
        itemDistanceValue = value
    }
    
    switch layout {
    case .grid:
        return itemDistanceValue
    case .horizontal, .vertical:
        let multiplier: CGFloat = abs((sqrt(3)-sqrt(2)*pow(3, 0.25))/sqrt(3))
        return itemDistanceValue + multiplier * itemDiameter + multiplier * itemDistanceValue
    }
}
