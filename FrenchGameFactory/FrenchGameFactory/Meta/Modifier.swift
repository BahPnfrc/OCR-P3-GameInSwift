//
//  Modifier.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 13/03/2021.
//

import Foundation

// MARK: Class : Modifier
class Modifier {
    // Modify properties of toons with random bonus and malus
    private static let malusRange: ClosedRange<Double> = 0.80...0.95
    private static let sameRange: ClosedRange<Double> = 0.95...1.05
    private static let bonusRange: ClosedRange<Double> = 1.05...1.20
    static let malus = { return Double.random(in: malusRange)}
    static let same = { return Double.random(in: sameRange)}
    static let bonus = { return Double.random(in: bonusRange)}
}
