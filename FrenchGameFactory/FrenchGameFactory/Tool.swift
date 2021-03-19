//
//  Tool.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 05/03/2021.
//

import Foundation

// MARK: Protocols
protocol ProfilSet {
    var isUpdated: Bool {get set}
    var pic: String {get}
    var name: String {get}
}
protocol DamageSet {
    var damageSet:(
        biologic: (basic: Double, updated: Double),
        kinetic: (basic: Double, updated: Double),
        thermic: (basic: Double, updated: Double))
        {get}
}

// MARK: Mother class
class Tool: ProfilSet, DamageSet{
    
    // PROFIL SET
    var isUpdated: Bool = false
    let pic: String
    let name: String

    func getPicWithName() -> String {
        self.pic + " " + self.name
    }
    
    // DAMAGE SET
    var damageSet : (
        biologic: (basic: Double, updated: Double),
        kinetic: (basic: Double, updated: Double),
        thermic: (basic: Double, updated: Double))
        = ((Setting.Tool.basicDamage, Setting.Tool.updatedDamage),
           (Setting.Tool.basicDamage, Setting.Tool.updatedDamage),
           (Setting.Tool.basicDamage, Setting.Tool.updatedDamage))
    
    func getBiologicDamage() -> Double {
        isUpdated == true ? damageSet.biologic.updated : damageSet.biologic.basic
    }
    func getKineticDamage() -> Double {
        isUpdated == true ? damageSet.kinetic.updated : damageSet.kinetic.basic
    }
    func getThermicDamage() -> Double {
        isUpdated == true ? damageSet.thermic.updated : damageSet.thermic.basic
    }
    
    fileprivate static func getAgeExtraModifier (
        _ age: Age,
        _ modifier: (forJunior: Double, forAdult: Double, forSenior: Double)) -> Double {
        
        return age == Age.isJunior ? modifier.forJunior :
            age == Age.isAdult ? modifier.forAdult :
            modifier.forSenior
    }
    
    init (_ pic: String,
          _ name: String) {
        (self.pic, self.name)  = (pic, name)
    }
}

// MARK: Daughter : Biologic Weapon
class BiologicWeapon: Tool {
    
    static let extraModifier = Setting.Tool.biologicWeaponAgeExtraModifier
    
    init(_ age: Age,
         _ pic: String,
         _ name: String) {
        super.init(pic, name)
    
        let byThisValue: Double = Tool.getAgeExtraModifier(age, BiologicWeapon.extraModifier)
        if byThisValue != 1 {
            self.damageSet.biologic.basic *= byThisValue
            self.damageSet.biologic.updated *= byThisValue
        }
     }
}

// MARK: Daughter : Kinetic Weapon
class KineticWeapon: Tool {
    
    static let extraModifier = Setting.Tool.kineticWeaponAgeExtraModifier
    
    init(_ age: Age,
         _ pic: String,
         _ name: String) {
        super.init(pic, name)
        
        let byThisValue: Double = Tool.getAgeExtraModifier(age, KineticWeapon.extraModifier)
        if byThisValue != 1 {
            self.damageSet.kinetic.basic *= byThisValue
            self.damageSet.kinetic.updated *= byThisValue
        }
     }
}

// MARK: Daughter : Thermic Weapon
class ThermicWeapon: Tool {
    
    static let extraModifier = Setting.Tool.thermicWeaponAgeExtraModifier
    
    init(_ age: Age,
         _ pic: String,
         _ name: String) {
        super.init(pic, name)
        
        let byThisValue: Double = Tool.getAgeExtraModifier(age, ThermicWeapon.extraModifier)
        if byThisValue != 1 {
            self.damageSet.thermic.basic *= byThisValue
            self.damageSet.thermic.updated *= byThisValue
        }
     }
}
