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
    var name: (basic: String, updated: String) {get}
    var pic: (basic: String, updated: String) {get}
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
    
    var isUpdated: Bool = false
    let name: (basic: String, updated: String)
    let pic: (basic: String, updated: String)
    
    func getFullName() -> String{
        return isUpdated == true ?
        pic.updated + " " + name.updated :
        pic.basic + " " + name.updated
    }

    var damageSet : (
        biologic: (basic: Double, updated: Double),
        kinetic: (basic: Double, updated: Double),
        thermic: (basic: Double, updated: Double))
        = ((Setting.Tool.basicDamage, Setting.Tool.updatedDamage),
           (Setting.Tool.basicDamage, Setting.Tool.updatedDamage),
           (Setting.Tool.basicDamage, Setting.Tool.updatedDamage))
    
    func getName() -> String {
        return isUpdated == true ? name.updated : name.basic
    }
    func getPicture() -> String {
        return isUpdated == true ? pic.basic : pic.updated
    }
    func getBiologicDamage() -> Double {
        return isUpdated == true ? damageSet.biologic.updated : damageSet.biologic.basic
    }
    func getKineticDamage() -> Double {
        return isUpdated == true ? damageSet.kinetic.updated : damageSet.kinetic.basic
    }
    func getThermicDamage() -> Double {
        return isUpdated == true ? damageSet.thermic.updated : damageSet.thermic.basic
    }
    
    static func getAgeExtraModifier (
        _ age: Age,
        _ modifier: (forJunior: Double, forAdult: Double, forSenior: Double)) -> Double {
        
        return age == Age.isJunior ? modifier.forJunior :
            age == Age.isAdult ? modifier.forAdult :
            modifier.forSenior
    }
    
    init (_ basicPic: String,
          _ basicName: String,
          _ updatedPic: String,
          _ updatedName: String) {
        self.name = (basicName, updatedName)
        self.pic = (basicPic, updatedPic)
    }
}

// MARK: Daughter : Biologic Weapon
class BiologicWeapon: Tool {
    
    static let extraModifier = Setting.Tool.biologicWeaponAgeExtraModifier
    
    init(_ age: Age,
         _ basicPic: String,
         _ basicName: String,
         _ updatedPic: String,
         _ updatedName: String) {
        
        super.init(basicPic, basicName, updatedPic, updatedName)
    
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
         _ basicPic: String,
         _ basicName: String,
         _ updatedPic: String,
         _ updatedName: String) {
        
        super.init(basicPic, basicName, updatedPic, updatedName)
    
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
         _ basicPic: String,
         _ basicName: String,
         _ updatedPic: String,
         _ updatedName: String) {
        
        super.init(basicPic, basicName, updatedPic, updatedName)
    
        let byThisValue: Double = Tool.getAgeExtraModifier(age, ThermicWeapon.extraModifier)
        if byThisValue != 1 {
            self.damageSet.thermic.basic *= byThisValue
            self.damageSet.thermic.updated *= byThisValue
        }
     }
}
