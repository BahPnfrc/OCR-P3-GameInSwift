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
    
    var weapon: Weapon?
    var isInTeam = false
    
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
    init(
        withID id: Int,
        withGender gender: Gender,
        withAge age: Age,
        withPic pic: String,
        withTitle title: String ){
        
        self.ID = id
        self.gender = gender
        self.age = age
        self.pic = pic
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
    
    static func resetAllID() {
        for toon in Engineer.All { toon.ID = 0 }
        for toon in Military.All { toon.ID = 0 }
        for toon in Medical.All { toon.ID = 0 }
    }
    
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
    func getFirstPromptInfos() -> String {
        let name: String = String(ID) + ". " +  getPicWithName() + " " + gender.rawValue
        let age: String = "A " + self.age.rawValue
        let tool: String = "armed with " + getHisOrHer() + self.weapon!.getPicWithName()
        return name + " : " + age + " " + tool
    }
    func getFightInfos() -> String {
        let name : String = String(ID) + ". " + getPicWithName()
        let tool : String = self.weapon!.getPicWithName()
        return name + " with " + getHisOrHer() + tool
    }
    func getLifeBar() -> String {
        // A - Percent as a string
        let totalHP = Setting.Toon.defaultLifeSet.hitpoints
        let leftHP = self.lifeSet.hitpoints
        var percentLeft: Int = getPercent(actuel: leftHP, total: totalHP)
        let percentAsString = " " + String(percentLeft) + "%"
        // B - Percent as a picture
        let visualModel: String =
            String(repeating: "🟥,", count: 4) +
            String(repeating: "🟧,", count: 4) +
            String(repeating: "🟨,", count: 4) +
            String(repeating: "🟩,", count: 15) + "🟩"
        let model: [String] = visualModel.components(separatedBy: ",")
        let percentPerPicture = 100 / model.count
        var lifeBar: String = ""
        for currentIconIndex in 0...model.count - 1 { // For each icon
            if percentLeft >= percentPerPicture {
                lifeBar.append(model[currentIconIndex]) // Add the colored icon
                percentLeft -= percentPerPicture
            } else {
                lifeBar.append("⬜️") // Add a blanck icon
            }
        }
        return lifeBar + percentAsString
    }
    private func getPercent(actuel: Int, total: Int) -> Int {
        let actuelDouble: Double = Double(actuel)
        let totalDouble: Double = Double(total)
        let result = actuelDouble * 100 / totalDouble
        return Int(result)
    }
    
}

// MARK: Extension : Random Name
extension Toon {
   
    private static var defaultNameForMan: [String] =
        ["Zenon", "Danton", "Gatien", "Zephir", "Clodomir",
        "Petrus", "Lazare", "Flavien", "Ovide", "Medard"]
    
    private static var defaultnameForWoman: [String] =
        ["Evodie", "Rejane", "Vitaline", "Nonce", "Toussine",
         "Firmine", "Peroline", "Gratienne", "Renelle", "Zilda"]
    
    func getRandomName() -> String {
        var randomName: String
        if self.gender == .isMan {
            Toon.defaultNameForMan.shuffle()
            randomName = Toon.defaultNameForMan.first!
            Toon.defaultNameForMan.removeFirst()
        } else {
            Toon.defaultnameForWoman.shuffle()
            randomName = Toon.defaultnameForWoman.first!
            Toon.defaultnameForWoman.removeFirst()
        }
        return randomName
    }
    
}
// MARK: Extension : Not used any
extension Toon {
    
    static func getRandomPic(_ pics: String) -> String {
       return pics.components(separatedBy: ",").randomElement()!
   }
    
}
