//
//  TeamUseMedicine.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 29/03/2021.
//

import Foundation

class TeamUseMedicine: Medicine {
    
    func use(OnTeam player: Player) -> Int {
        var restored: Int = 0
        let expectedHitpoints: Double = Double(Setting.Toon.defaultLifeSet.hitpoints) * self.factor
        for toon in player.toons {
            if toon.isAlive() {
                if toon.lifeSet.isSick == true { toon.lifeSet.isSick = false }
                restored += restoreHitpointsWithStats(ofToon: toon, to: Int(expectedHitpoints))
            }
        }
        var restoredText: String = ""
        if (0...0).contains(restored) {
            restoredText = "They gained no hitpoints so it was a pure waste 👎"
        } else if (1...300).contains(restored) {
            restoredText = "They gained a few set of \(restored) hitpoints 👍"
        } else {
            restoredText = "They gained a whole bunch of \(restored) hitpoints 💪"
        }
        Console.write(0, 1, """
            Team of \(player.name) experienced the \(self.getPicWithName()) :
            \(restoredText.withNum())
            """, 1)
        self.left -= 1
        return restored // #STAT
    }
    
}
