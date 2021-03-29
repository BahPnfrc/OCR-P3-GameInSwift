//
//  SingleUseMedicine.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 29/03/2021.
//

import Foundation

final class SingleUseMedicine: Medicine {
    
    func use(onToon toon: Toon) {
        let expectedHitpoints: Double = Double(Setting.Toon.defaultLifeSet.hitpoints) * self.factor
        let restored = restoreHitpoints(ofToon: toon, to: Int(expectedHitpoints))
        if restored > 0 {
            Console.write(1, 1, """
                ℹ️\(toon.getPicWithName()) just had a \(self.getPicWithName()) :
                \(toon.getHeOrShe(withMaj: true)) gained \(restored) hitpoints as expected 👍
                """, 1)
        } else { Console.write(1, 1, """
                    ℹ️\(toon.getPicWithName()) just had a \(self.getPicWithName()) :
                    For some reason the medicine had no effect 👎
                    """, 1) }
        self.left -= 1
    }
    
}
