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
    func getHitPointsLeft() -> Int {return lifeSet.hitpoints}
    func getPercentLeft() -> Int {
        let actuelDouble: Double = Double(getHitPointsLeft())
        let totalDouble: Double = Double(Setting.Toon.defaultLifeSet.hitpoints)
        let result = actuelDouble * 100 / totalDouble
        if result < 1 { return 0}
        return Int(result)
    }
    func isAlive() -> Bool {return lifeSet.hitpoints > 0}
    func isSick() -> Bool {return lifeSet.isSick}
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
    var statSet: (
        roundPlayed: Int,
        sicknessDamage: Int,
        totalDamage: (received: Int, given: Int),
        bestDamage: (received: Int, given: Int),
        medicine: (received: Int, given: Int)
    ) {get set}
}

// MARK: Enumations
enum Gender: String, CaseIterable {
    case isMan = "man", isWoman = "woman"
}
enum Age: String, CaseIterable {
    case isJunior = "mid 30'", isAdult = "mid 40'", isSenior = "mid 50'"
}

// MARK: Class
class Toon: LifeSet, SkillSet, FightSet, StatSet {

    let ID: Int
    var promptID: Int = 0
    let gender: Gender
    let age: Age
    
    var name: String?
    let pic: String
    let title: String
    
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
    
    // MARK: StatSet
    var statSet:
        (roundPlayed: Int, sicknessDamage: Int,
         totalDamage: (received: Int, given: Int),
         bestDamage: (received: Int, given: Int),
         medicine: (received: Int, given: Int))
        = (0, 0,
           (0, 0),
           (0, 0),
           (0, 0))
    
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
            self.skillSet.strenght *= ToonModifier.bonus()
            self.skillSet.accuracy *= ToonModifier.malus()
        case .isWoman:
            self.skillSet.strenght *= ToonModifier.malus()
            self.skillSet.accuracy *= ToonModifier.bonus()

        switch self.age {
        case .isJunior:
            self.skillSet.forsight *= ToonModifier.malus()
            self.skillSet.agility *= ToonModifier.bonus()
        case .isAdult:
            self.skillSet.forsight *= ToonModifier.same()
            self.skillSet.agility *= ToonModifier.same()
        case .isSenior:
            self.skillSet.forsight *= ToonModifier.bonus()
            self.skillSet.agility *= ToonModifier.malus()
            }
        }
    }
}
// MARK: Hitpoints
extension Toon {
   
    func loseHP(from attacker: Toon?, for amount: Int){
        // A - Defender
        lifeSet.hitpoints -= amount
        statSet.totalDamage.received += amount
        if amount > statSet.bestDamage.received {
            statSet.bestDamage.received = amount
        }
        // B - Attacker
        guard let attacker = attacker else {
            statSet.sicknessDamage += amount
            return
        }
        attacker.statSet.roundPlayed += 1
        attacker.statSet.totalDamage.given += amount
        if amount > attacker.statSet.bestDamage.given {
            attacker.statSet.bestDamage.given = amount
        }
        // C - Sickness check
        if !isSick() {
            ExtraWeapon.spreadVirus(from: attacker, to: self)
        }
    }
    func gainHP(from medical: MedicalToon, for amount: Int){
        // Defender
        lifeSet.hitpoints += amount
        statSet.medicine.received += amount
        // Doctor
        medical.statSet.medicine.given += amount
    }
}

// MARK: Extension : Random Name
extension Toon {
   
    private static var defaultNameForMan: [String] =
        ["Zenon", "Danton", "Gatien", "Zephir", "Clodomir",
        "Petrus", "Lazare", "Flavien", "Ovide", "Medard"]
    
    private static var defaultNameForWoman: [String] =
        ["Evodie", "Rejane", "Vitaline", "Nonce", "Toussine",
         "Firmine", "Peroline", "Gratienne", "Renelle", "Zilda"]
    
    func getRandomName() -> String {
        var randomName: String
        var rightArray = self.gender == .isMan ?
            Toon.defaultNameForMan : Toon.defaultNameForWoman
        rightArray.shuffle()
        randomName = rightArray.first!
        rightArray.removeFirst()
        return randomName
    }
    static func getStaticRandomName(forToon toon: Toon) -> String {
        var randomName: String
        var rightArray = toon.gender == .isMan ?
            Toon.defaultNameForMan : Toon.defaultNameForWoman
        rightArray.shuffle()
        randomName = rightArray.first!
        rightArray.removeFirst()
        return randomName
    }
}
// MARK: Extension : Retrieve data
extension Toon {
    
    static func resetAllPromptID() {
        for toon in EngineerToon.All { toon.promptID = 0 }
        for toon in MilitaryToon.All { toon.promptID = 0 }
        for toon in MedicalToon.All { toon.promptID = 0 }
    }
    
    func getHeOrShe(withMaj:Bool = false) -> String {
        gender == .isMan ?
            (withMaj == true ? "He " : "he ") :
            (withMaj == true ? "She " : "she ")
    }
    func getHisOrHer(withMaj:Bool = false) -> String {
        gender == .isMan ?
            (withMaj == true ? "His " : "his ") :
            (withMaj == true ? "Her " : "her ")
    }
    func getAgeWithGender() -> String {
        age.rawValue + " " + gender.rawValue
    }
    func getPicWithName() -> String {
        var pic = self.pic
        if !isAlive() { pic = "❌" + pic }
        else if self.lifeSet.isSick == true { pic = "🦠" + pic }
        guard let name = name else { return  pic + " " + title }
        return pic + " " + title + " " + name
    }
    func getChooseToonPrompt() -> String {
        let name: String = String(promptID) + ". " +  getPicWithName() + " " + gender.rawValue
        let age: String = "a " + self.age.rawValue
        let tool: String = "with " + getHisOrHer() + weapon!.getPicWithName()
        return name + " : " + age + " " + tool
    }
    func getFightPrompt() -> String {
        let name : String = String(promptID).withNum() + ". " + getPicWithName()
        let tool : String = weapon!.getPicWithName()
        return name + " with " + getHisOrHer() + tool
    }
    
    func getFightPromptWithBar() -> String {
        return getFightPrompt() + "\n" + getLifeBar() + "\n"
    }
    
    func getHitpointsAndPercent() -> String {
        return "\(self.lifeSet.hitpoints) HP left : \(getPercentLeft())%"
    }
    
    func getLifeBar(withBlocks blocks: Int = 28) -> String {
        // A - Percent as a string
        let percentLeft: Int = self.getPercentLeft()
        var percentText: String = String(percentLeft)
        if percentLeft == 0 && self.isAlive() { percentText = "≈0"}
        let percentAsString = " " + percentText + "%"
        // B - Percent as a picture
        let barLenght: Int = blocks
        let model: [(percent: Int, block: String)] =
        [(60, "🟩"), (40, "🟨"), (20, "🟧"),(0, "🟥")]
        var lifeBar: String = ""
        for step in model {
            if percentLeft > step.percent {
                var coloredBlockNumber: Int = percentLeft * barLenght / 100
                if coloredBlockNumber == 0 { coloredBlockNumber = 1 } //
                let blankBlockNumber: Int = barLenght - coloredBlockNumber
                lifeBar.append(String(repeating: step.block, count: coloredBlockNumber))
                lifeBar.append(String(repeating: "⬜️", count: blankBlockNumber))
                return lifeBar + percentAsString
            }
        }
        lifeBar.append(String(repeating: "⬜️", count: barLenght))
        return lifeBar + percentAsString
    }
}
