//
//  Weapon.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 21/03/2021.
//

import Foundation

protocol DamageSet {
    var isUpdated: Bool  {get set}
    var damageSet:(
        biologic: (basic: Double, updated: Double),
        kinetic: (basic: Double, updated: Double),
        thermic: (basic: Double, updated: Double))
        {get}
}

class Weapon : Tool, DamageSet {
   
    var isUpdated: Bool = false
    
    // DAMAGE SET
    var damageSet : (
        biologic: (basic: Double, updated: Double),
        kinetic: (basic: Double, updated: Double),
        thermic: (basic: Double, updated: Double))
        = ((Setting.Weapon.basicDamage, Setting.Weapon.updatedDamage),
           (Setting.Weapon.basicDamage, Setting.Weapon.updatedDamage),
           (Setting.Weapon.basicDamage, Setting.Weapon.updatedDamage))
    
    func getBiologicDamage() -> Double {
        isUpdated == true ? damageSet.biologic.updated : damageSet.biologic.basic
    }
    func getKineticDamage() -> Double {
        isUpdated == true ? damageSet.kinetic.updated : damageSet.kinetic.basic
    }
    func getThermicDamage() -> Double {
        isUpdated == true ? damageSet.thermic.updated : damageSet.thermic.basic
    }
    
    func getGenderExtraModifier (
        _ gender: Gender,
        _ modifierSet: (forMan: Double, forWoman: Double)) -> Double {
        
        return gender == Gender.isMan ? modifierSet.forMan :
            modifierSet.forWoman
    }
    func getAgeExtraModifier (
        _ age: Age,
        _ modifierSet: (forJunior: Double, forAdult: Double, forSenior: Double)) -> Double {
        
        return age == Age.isJunior ? modifierSet.forJunior :
            age == Age.isAdult ? modifierSet.forAdult :
            modifierSet.forSenior
    }

    static func getDamage(from attacker: Toon, to defender: Toon) -> Double {
        let biologicDamage: Double = attacker.weapon!.getBiologicDamage()
            * attacker.getBiologicAttack() / defender.getBiologicDefense()
        let kineticDamage: Double = attacker.weapon!.getKineticDamage()
            * attacker.getKineticAttack() / defender.getKineticDefense()
        let thermicDamage: Double = attacker.weapon!.getThermicDamage()
            * attacker.getThermicAttack() / defender.getThermicDefense()
        let damage: Double = (biologicDamage + kineticDamage + thermicDamage)
            * attacker.getStrenght() / defender.getAgility()
            * attacker.getAccuracy() / defender.getForsight()
        return damage
    }
}



