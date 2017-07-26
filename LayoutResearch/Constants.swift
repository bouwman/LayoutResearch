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
    }
    struct Interface {
        static let descriptionItemMargin: CGFloat = 50
        static let searchLayoutMargin: CGFloat = 200
        static let introLayoutMargin: CGFloat = 30
        static let shapeCount: Int = 27
    }
}

enum SettingsString: String {
    case isParticipating
    case consentPath
    case resultCSVPath
}

extension UIColor {
    static func searchColorFor(id: Int) -> UIColor {
        return UIColor(named: "Color\(id)") ?? UIColor.black
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
