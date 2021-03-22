//
//  KineticWeapon.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 22/03/2021.
//

import Foundation

// MARK: Daughter : Kinetic Weapon
class KineticWeapon: Weapon {
    
    static let genderExtraModifier = Setting.Weapon.kineticGenderExtraModifier
    static let ageExtraModifier = Setting.Weapon.kineticAgeExtraModifier
    
    init(withGender gender: Gender,
         withAge age: Age,
         withPic pic: String,
         withName name: String) {
        
        super.init(withPic: pic, withName: name)
        
        let genderModifier: Double =
            self.getGenderExtraModifier(gender, KineticWeapon.genderExtraModifier)
        if genderModifier != 1 {
            self.damageSet.kinetic.basic *= genderModifier
            self.damageSet.kinetic.updated *= genderModifier
        }
        
        let ageModifier: Double =
            self.getAgeExtraModifier(age, KineticWeapon.ageExtraModifier)
        if ageModifier != 1 {
            self.damageSet.kinetic.basic *= ageModifier
            self.damageSet.kinetic.updated *= ageModifier
        }
     }
}
