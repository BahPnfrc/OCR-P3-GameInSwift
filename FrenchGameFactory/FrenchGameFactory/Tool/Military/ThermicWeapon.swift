//
//  ThermicWeapon.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 22/03/2021.
//

import Foundation

// MARK: Daughter : Thermic Weapon
class ThermicWeapon: Weapon {
    
    static let genderExtraModifier = Setting.Weapon.thermicGenderExtraModifier
    static let extraModifier = Setting.Weapon.thermicAgeExtraModifier
    
    init(withGender gender: Gender,
         withAge age: Age,
         withPic pic: String,
         withName name: String) {
        
        super.init(withPic: pic, withName: name)
        
        let genderModifier: Double =
            self.getGenderExtraModifier(gender, ThermicWeapon.genderExtraModifier)
        if genderModifier != 1 {
            self.damageSet.thermic.basic *= genderModifier
            self.damageSet.thermic.updated *= genderModifier
        }
        
        let ageModifier: Double =
            self.getAgeExtraModifier(age, ThermicWeapon.extraModifier)
        if ageModifier != 1 {
            self.damageSet.thermic.basic *= ageModifier
            self.damageSet.thermic.updated *= ageModifier
        }
     }
}
