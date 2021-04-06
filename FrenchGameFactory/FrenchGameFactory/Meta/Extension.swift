//
//  Extension.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 06/04/2021.
//

import Foundation

extension String {
    func withNum() -> String {
        var result: String = self
        let changeSet: [(from: String, to: String)] =
            [("0", "0️⃣"), ("1", "1️⃣"), ("2", "2️⃣"), ("3", "3️⃣"), ("4", "4️⃣"),
             ("5", "5️⃣"), ("6", "6️⃣"), ("7", "7️⃣"), ("8", "8️⃣"), ("9", "9️⃣")]
        for change in changeSet {
            result = result.replacingOccurrences(of: change.from, with: change.to)
        }
        return result
    }
    func withEmo() -> String {
        var result: String = self
        let changeSet: [(from: String, to: String)] =
            [("woman ", "🚺 "), ("man ","🚹 ")]
        for change in changeSet {
            result = result.replacingOccurrences(of: change.from, with: change.to)
        }
        return result
    }
}
