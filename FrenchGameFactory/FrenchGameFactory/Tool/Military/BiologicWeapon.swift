//
//  BiologicWeapon.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 22/03/2021.
//

import Foundation

// MARK: Biologic Weapon
class BiologicWeapon: Weapon {
    
    static let genderExtraModifier = Setting.Weapon.biologicGenderExtraModifier
    static let ageExtraModifier = Setting.Weapon.biologicAgeExtraModifier
    
    init(withGender gender: Gender,
         withAge age: Age,
         withPic pic: String,
         withName name: String) {
        
        super.init(withPic: pic, withName: name)
    
        let genderModifier: Double =
            self.getGenderExtraModifier(gender, BiologicWeapon.genderExtraModifier)
        if genderModifier != 1 {
            self.damageSet.biologic.basic *= genderModifier
            self.damageSet.biologic.updated *= genderModifier
        }
        
        let ageModifier: Double =
            self.getAgeExtraModifier(age, BiologicWeapon.ageExtraModifier)
        if ageModifier != 1 {
            self.damageSet.biologic.basic *= ageModifier
            self.damageSet.biologic.updated *= ageModifier
        }
     }
}
