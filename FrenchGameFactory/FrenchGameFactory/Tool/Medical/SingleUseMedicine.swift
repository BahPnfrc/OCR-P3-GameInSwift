//
//  SingleUseMedicine.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 29/03/2021.
//

import Foundation

final class SingleUseMedicine: Medicine {
    
    func use(fromDoctor doctor: MedicalToon, onToon toon: Toon){
        guard toon.isAlive() else { return }
        if toon.isSick() { toon.lifeSet.isSick = false }
        let hitpointsExpected: Double = Double(Setting.Toon.defaultLifeSet.hitpoints) * self.factor
        let draf: Double = hitpointsExpected - Double(toon.getHitPointsLeft())
        let hitpointsToRestore: Int = draf > 0 ? Int(draf) : 0
        if hitpointsToRestore > 0 {
            toon.gainHP(from: doctor, for: hitpointsToRestore)
            Console.write(0, 1, """
                ℹ️. \(toon.getPicWithName()) just had a \(self.getPicWithName()) :
                \(toon.getHeOrShe(withMaj: true))gained \(hitpointsToRestore) hitpoints as expected 👍
                """, 1)
        } else { Console.write(0, 1, """
                    ℹ️. \(toon.getPicWithName()) just had a \(self.getPicWithName()) :
                    For some reason the medicine had no effect 👎
                    """, 1)
        }
        self.left -= 1
    }
    
}
