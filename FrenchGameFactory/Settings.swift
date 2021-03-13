//
//  Settings.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 12/03/2021.
//

import Foundation


class Setting {
    
    class Toon {
        
    }
    
    class Tool {
        
        static let basicDamage: Double = 100
        static let updatedDamage: Double = 150
        static let expectedBasicDamage: Double = basicDamage * 3
        static let expectedUpdatedDamage: Double = updatedDamage * 3
        
        static let biologicWeaponAgeExtraModifier:
            (forJunior: Double, forAdult: Double, forSenior: Double)
            = (1.0, 1.0, 1.0)
        static let kineticWeaponAgeExtraModifier:
            (forJunior: Double, forAdult: Double, forSenior: Double)
            = (1.0, 1.0, 1.0)
        static let thermicWeaponAgeExtraModifier:
            (forJunior: Double, forAdult: Double, forSenior: Double)
            = (1.0, 1.0, 1.0)
    }
    
    
    
    
}
