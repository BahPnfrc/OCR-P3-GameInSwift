//
//  DamageCase.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 30/03/2021.
//

import Foundation

class DamageCase {
    
    let attacker: Toon
    let defender: Toon
    let damage: Double
    let isLethal: Bool
    
    init( attacker: Toon,
          defender: Toon,
          damage: Double,
          isLethal: Bool) {
        self.attacker = attacker
        self.defender = defender
        self.damage = damage
        self.isLethal = isLethal
        
    }
}
