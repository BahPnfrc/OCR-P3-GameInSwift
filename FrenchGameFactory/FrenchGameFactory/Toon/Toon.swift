//
//  Toon.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 05/03/2021.
//

import Foundation

// MARK: Protocol : LifeSet
protocol LifeSet {
    var lifeSet: (
        hitpoints: Int,
        isSick: Bool)
        {get set}
}
extension LifeSet {
    mutating func isHit(amount: Int){ lifeSet.hitpoints -= amount}
    mutating func isHealed(amount: Int){lifeSet.hitpoints += amount}
    func hitPointsLeft() -> Int {return lifeSet.hitpoints}
    func isAlive() -> Bool {return lifeSet.hitpoints > 0}
}

// MARK: Protocol : SkillSet
protocol SkillSet {
    var skillSet: (
        strenght: Double, // Balance out with accuracy
        accuracy: Double, // Balance out with strenght
        agility: Double, //  Balance out with forsight
        forsight: Double) // Balance out with agility
        {get}
}
extension SkillSet {
    func getStrenght() -> Double {return skillSet.strenght}
    func getAccuracy() -> Double {return skillSet.accuracy}
    func getForsight() -> Double {return skillSet.forsight}
    func getAgility() -> Double {return skillSet.agility}
    func getAverageSkillAttack() -> Double {return getStrenght() * getAccuracy()}
    func getAverageSkillDefense() -> Double {return getForsight() * getAgility()}
    func getGlobalSkillSet() -> Double {return getAverageSkillAttack() * getAverageSkillDefense()}
}

// MARK: Protocol : FightSet
protocol FightSet {
    var fightSet: (
            biologic: (defense: Double, attack: Double),
            kinetic: (defense: Double, attack: Double),
            thermic: (defense: Double, attack: Double))
            {get}
}
extension FightSet {
    func getBiologicAttack() -> Double {return fightSet.biologic.attack}
    func getBiologicDefense() -> Double {return fightSet.biologic.defense}
    func getKineticAttack() -> Double {return fightSet.kinetic.attack}
    func getKineticDefense() -> Double {return fightSet.kinetic.defense}
    func getThermicAttack() -> Double {return fightSet.thermic.attack}
    func getThermicDefense() -> Double {return fightSet.thermic.defense}
    func getAverageFightAttack() -> Double {return getBiologicAttack() * getKineticAttack() * getThermicAttack()}
    func getAverageFightDefense() -> Double {return getBiologicDefense() * getKineticDefense() * getThermicDefense()}
    func getGlobalFightSet() -> Double {return getAverageFightAttack() * getAverageFightDefense()}
}

protocol StatSet {
    var roundPlayed: Int {get set}
    var damage: (received: Int, given: Int, bestHit: Int) {get set}
    var medecine: (received: Int, given: Int) {get set}
}

// MARK: Enumations
enum Gender: String, CaseIterable {
    case isMan = "man", isWoman = "woman"
}
enum Age: String, CaseIterable {
    case isJunior = "mid 30'", isAdult = "mid 40'", isSenior = "mid 50'"
}

// MARK: Class
class Toon: LifeSet, SkillSet, FightSet {
    
    var ID: Int
    var gender: Gender
    var age: Age
    
    var name: String?
    var pic: String
    var title: String
    
    var tool: Tool?
    
    // MARK: LifeSet
    var lifeSet: (
        hitpoints: Int,
        isSick: Bool) =
        Setting.Toon.defaultLifeSet
    
    // MARK: SkillSet
    var skillSet: (
        strenght: Double,
        accuracy: Double,
        agility: Double,
        forsight: Double)
        = (Setting.Toon.defaultSkillSet,
           Setting.Toon.defaultSkillSet,
           Setting.Toon.defaultSkillSet,
           Setting.Toon.defaultSkillSet)
    
    lazy var averageSkillAttack: Double = getAverageSkillAttack()
    lazy var averageSkillDefense: Double = getAverageSkillDefense()
    
    // MARK: FightSet
    var fightSet: (
        biologic: (defense: Double, attack: Double),
        kinetic: (defense: Double, attack: Double),
        thermic: (defense: Double, attack: Double))
        = ((Setting.Toon.defaultFightSet),
           (Setting.Toon.defaultFightSet),
           (Setting.Toon.defaultFightSet))
    
    lazy var averageFightAttack: Double = getAverageFightAttack()
    lazy var averageFightDefense: Double = getAverageFightDefense()
    
    // MARK: GlobalSet
    lazy var globalSkillSet: Double = getGlobalSkillSet()
    lazy var globalFightSet: Double = getGlobalFightSet()
    lazy var globalSet: Double = globalSkillSet * globalFightSet
    
    // MARK: Init
    init(_ id: Int, _ gender: Gender, _ age: Age, _ icon: String, _ title: String ){
        
        self.ID = id
        self.gender = gender
        self.age = age
        self.pic = icon
        self.title = title

        switch self.gender {
        case .isMan:
            self.skillSet.strenght *= Modifier.bonus()
            self.skillSet.accuracy *= Modifier.malus()
        case .isWoman:
            self.skillSet.strenght *= Modifier.malus()
            self.skillSet.accuracy *= Modifier.bonus()

        switch self.age {
        case .isJunior:
            self.skillSet.forsight *= Modifier.malus()
            self.skillSet.agility *= Modifier.bonus()
        case .isAdult:
            self.skillSet.forsight *= Modifier.same()
            self.skillSet.agility *= Modifier.same()
        case .isSenior:
            self.skillSet.forsight *= Modifier.bonus()
            self.skillSet.agility *= Modifier.malus()
            }
        }
    }
}
// MARK: Extension : Retrieve data
extension Toon { //
    func getHisOrHer() -> String {
        gender == .isMan ? "his " : "her "
    }
    func getAgeWithGender() -> String {
        age.rawValue + " " + gender.rawValue
    }
    func getPicWithName() -> String {
        guard let name = name else {
            return  pic + " " + title
        }
        return pic + " " + title + " " + name
    }
    func getPresentation() -> String {
        let name: String = String(ID) + ". " +  getPicWithName() + " " + gender.rawValue
        let age: String = "A " + self.age.rawValue
        let tool: String = "armed with " + getHisOrHer() + self.tool!.getPicWithName()
        return name + " : " + age + " " + tool
    }
}
// MARK: Extension : Not used any
extension Toon {
    static func getRandomPic(_ pics: String) -> String {
       return pics.components(separatedBy: ",").randomElement()!
   }
}
