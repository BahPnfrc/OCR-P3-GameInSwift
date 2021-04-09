//
//  Settings.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 12/03/2021.
//

import Foundation

final class Setting {
    
    private static let useDefault: Bool = true
    
    final class Game {
        
        static var fastPlayEnabled: Bool = false
        static let fastPlayLevel: Level
            = useDefault ? .isHard : .isHard
        static let fastPlayOrder: Order
            = useDefault ? .chance : .second
    }

    final class Toon {
        
        static let defaultLifeSet: (hitpoints: Int, isSick: Bool)
            = useDefault ? (1000, false) : (1000, false)
        static let defaultSkillSet: Double
            = useDefault ? 1.0 : 1.0
        static let defaultFightSet: (defense: Double, attack: Double)
            = useDefault ? (1.0, 1.0) : (1.0, 1.0)
    }
    
    final class Weapon {
        
        static let basicDamage: Double
            = useDefault ? 100 : 100
        static let updatedDamage: Double
            = useDefault ? 110: 110
        
        static let expectedBasicDamage: Double
            = useDefault ? basicDamage * 3 : basicDamage * 3
        static let expectedUpdatedDamage: Double
            = useDefault ? updatedDamage * 3 : updatedDamage * 3
        
        static let kineticGenderExtraModifier:
            (forMan: Double, forWoman: Double)
            = useDefault ? (1.0, 1.0) :  (1.0, 1.0)
        static let thermicGenderExtraModifier:
            (forMan: Double, forWoman: Double)
            = useDefault ? (1.0, 1.0) :  (1.0, 1.0)
        static let biologicGenderExtraModifier:
            (forMan: Double, forWoman: Double)
            = useDefault ? (1.0, 1.0) :  (1.0, 1.0)
        
        static let kineticAgeExtraModifier:
            (forJunior: Double, forAdult: Double, forSenior: Double)
            = useDefault ? (1.0, 1.0, 1.0) : (1.0, 1.0, 1.0)
        static let thermicAgeExtraModifier:
            (forJunior: Double, forAdult: Double, forSenior: Double)
            = useDefault ? (1.0, 1.0, 1.0) : (1.0, 1.0, 1.0)
        static let biologicAgeExtraModifier:
            (forJunior: Double, forAdult: Double, forSenior: Double)
            = useDefault ? (1.0, 1.0, 1.0) : (1.0, 1.0, 1.0)
    }
    
    final class ExtraWeapon {
        
        static let isActivated: Bool =
            useDefault ? true : true
        static let againstMachine: Bool =
            useDefault ? true : true
        static let isForcedOnEachRound: Bool =
            useDefault ? false : true
        static let isMultipleOf: Int =
            useDefault ? 3 : 3
        
        static let updatedDamageSetWithBonus:
            (biologic: Double, kinetic: Double, Thermic: Double) = useDefault ?
            (Weapon.updatedDamage * 1.2, Weapon.updatedDamage * 0.8, Weapon.updatedDamage * 0.8) :
            (Weapon.updatedDamage * 1.2, Weapon.updatedDamage * 0.8, Weapon.updatedDamage * 0.8)
           
        static let updatedDamageSetwithMalus:
            (biologic: Double, kinetic: Double, Thermic: Double) = useDefault ?
            (Weapon.updatedDamage * 0.8, Weapon.updatedDamage * 0.8, Weapon.updatedDamage * 0.8) :
            (Weapon.updatedDamage * 0.8, Weapon.updatedDamage * 0.8, Weapon.updatedDamage * 0.8)
    }
    
}
