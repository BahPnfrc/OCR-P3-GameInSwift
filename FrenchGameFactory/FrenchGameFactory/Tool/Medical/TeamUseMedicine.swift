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
                restored += restoreHitpointsWithStats(ofToon: toon, to: Int(expectedHitpoints))
            }
        }
        Console.write(1, 1, """
            Team of \(player.name) experienced the \(self.getPicWithName()) :
            They gained a total of \(restored) hitpoints 💪
            """, 1)
        self.left -= 1
        return restored // #STAT
    }
    
}
