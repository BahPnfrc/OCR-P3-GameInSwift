//
//  TeamUseMedicine.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 29/03/2021.
//

import Foundation

class TeamUseMedicine: Medicine {
    
    func use(fromDoctor doctor: MedicalToon, OnTeam player: Player){
        var restored: Int = 0
        let hitpointsExpected: Double = Double(Setting.Toon.defaultLifeSet.hitpoints) * self.factor
        for toon in player.toons {
            guard toon.isAlive() else { continue }
            if toon.isSick() { toon.lifeSet.isSick = false }
            let draf: Double = hitpointsExpected - Double(toon.getHitPointsLeft())
            let hitpointsToRestore: Int = draf > 0 ? Int(draf) : 0
            guard hitpointsToRestore > 0 else { continue }
            toon.gainHP(from: doctor, for: hitpointsToRestore)
            restored += hitpointsToRestore
        }
        let restoredText: String =
            restored == 0 ? "They gained no HP so it was a pure waste 👎" :
            (1...450).contains(restored) ? "They gained a few set of \(restored) HP 👍" :
            "They gained a whole bunch of \(restored) HP 💪"
        Console.write(0, 1, """
            Team of \(player.name) experienced the \(self.getPicWithName()) :
            \(restoredText.withNum())
            """, 1)
        self.left -= 1
    }
    
}
