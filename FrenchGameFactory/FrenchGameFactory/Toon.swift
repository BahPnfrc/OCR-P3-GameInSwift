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
        strenght: Double, // Must balance out with accuracy
        accuracy: Double, // Must balance out with strenght
        agility: Double, // Must balance out with forsight
        forsight: Double) // Must balance out with agility
        {get}
}
extension SkillSet {
    func getStrenght() -> Double {return skillSet.strenght}
    func getAccuracy() -> Double {return skillSet.accuracy}
    func getForsight() -> Double {return skillSet.forsight}
    func getAgility() -> Double {return skillSet.agility}
    
    func getAverageSkillAim() -> Double {return getStrenght() * getAccuracy()}
    func getAverageSkillDodge() -> Double {return getForsight() * getAgility()}
    func getAverageSkillSet() -> Double {return getAverageSkillAim() * getAverageSkillDodge()}
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
    func getAverageFightSet() -> Double {return getAverageFightAttack() * getAverageFightDefense()}
}

protocol StatSet {
    var roundPlayed: Int {get set}
    var damage: (given: Int, received: Int) {get set}
    var medecine: (given: Int, received: Int) {get set}
}

// MARK: Enumations
enum Gender: String, CaseIterable {
    case isMan = "man", isWoman = "woman"
}
enum Age: String, CaseIterable {
    case isJunior = "mid 30'", isAdult = "mid 40'", isSenior = "mid 50'"
}

// MARK: Mother class
class Toon: LifeSet, SkillSet, FightSet {

    var ID: Int
    var gender: Gender
    var age: Age
    
    var name: String?
    var pic: String
    var title: String
    
    var tool: Tool?

    private static var defLife: (Int, Bool) = (1000, false)
    var lifeSet: (
        hitpoints: Int,
        isSick: Bool)
        = Toon.defLife
    
    private static var defSkill: Double = 1.0
    var skillSet: (
        strenght: Double,
        accuracy: Double,
        agility: Double,
        forsight: Double)
        = (Toon.defSkill,
           Toon.defSkill,
           Toon.defSkill,
           Toon.defSkill)
    
    private static var defFight: (Double, Double) = (1.0, 1.0)
    var fightSet: (
        biologic: (defense: Double, attack: Double),
        kinetic: (defense: Double, attack: Double),
        thermic: (defense: Double, attack: Double))
        = ((Toon.defFight),
           (Toon.defFight),
           (Toon.defFight))
    
    lazy var averageSkillAim: Double = getAverageSkillAim()
    lazy var averageSkillDodge: Double = getAverageSkillDodge()
    lazy var averageSkillSet: Double = getAverageSkillSet()
    
    lazy var averageFightAttack: Double = getAverageFightAttack()
    lazy var averageFightDefense: Double = getAverageFightDefense()
    lazy var averageFightSet: Double = getAverageFightSet()
    
    lazy var averageSet: Double = averageSkillSet * averageFightSet
    
    
     static func getRandomPic(_ pics: String) -> String { // NOT USED
        return pics.components(separatedBy: ",").randomElement()!
    }

    
    init(_ id: Int, _ gender: Gender, _ age: Age, _ icon: String, _ role: String ){
        
        self.ID = id
        self.gender = gender
        self.age = age
        self.pic = icon
        self.title = role
        // Changing property according to gender
        switch self.gender {
        case .isMan:
            self.skillSet.strenght *= Modifier.bonus()
            self.skillSet.accuracy *= Modifier.malus()
        case .isWoman:
            self.skillSet.strenght *= Modifier.malus()
            self.skillSet.accuracy *= Modifier.bonus()
        // Changing property according to age
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

// MARK: Mother extension
extension Toon {
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

// MARK: Daughter : Engineer
final class Engineer: Toon {
    
    private static var newID: Int = 0
    private static func getNewID() -> Int {
        Engineer.newID += 1
        return Engineer.newID
    }

    init(_ gender: Gender,_ age: Age, _ icon: String, _ role: String) {
        super.init(Engineer.getNewID(), gender, age, icon, role)
        // Malus = Thermic, Bonus = Kinetic
        self.fightSet.biologic.defense *= Modifier.same()
        self.fightSet.biologic.attack *= Modifier.same()
        self.fightSet.kinetic.defense *= Modifier.bonus()
        self.fightSet.kinetic.attack *= Modifier.bonus()
        self.fightSet.thermic.defense *= Modifier.malus()
        self.fightSet.thermic.attack *= Modifier.malus()
    }
    
    static var All: [Toon] = [Engineer]()
    static func createAll(){
        var toon: (pic: String, title: String)
        var tool: (pic: String, name: String)
        for age in Age.allCases {
            for gender in Gender.allCases {
                switch (age, gender) {
                case (.isJunior, .isMan):
                    toon = ("👨‍🔧", "YoungMeccano") ; tool = ("🔧", "BloodStench Wrench")
                case (.isJunior, .isWoman):
                    toon = ("👩‍🔧,", "YoungMeccano") ; tool = ("🔩", "ChewThrough Screw")
                case (.isAdult, .isMan):
                    toon = ("👨‍💻", "MachineCoder") ; tool = ("💻", "MacBook Pro")
                case (.isAdult, .isWoman):
                    toon = ("👩‍💻", "MachineCoder") ; tool = ("🖥", "iMac Pro")
                case (.isSenior, .isMan):
                    toon = ("👨‍💼", "EmeritusProfessor") ; tool = ("📡", "Parabellum Parrabolla")
                case (.isSenior, .isWoman):
                    toon = ("👩‍💼", "EmeritusProfessor") ; tool = ("🦾", "Bionic Beef")
            }
            let newEngineer: Engineer = Engineer(gender, age, toon.pic, toon.title)
            newEngineer.tool = KineticWeapon(age, tool.pic, tool.name)
            All.append(newEngineer)
            }
        }
    }
}

// MARK: Daughter : Medical
final class Medical: Toon {
     
    private static var newID: Int = 0
    private static func getNewID() -> Int {
        Medical.newID += 1
        return Medical.newID
    }
    
    let lightMedicine = Tool("🩹", "Savage Bandage")
    let mediumMedicine = Tool("💊", "Precision Pill")
    let heavyMedicine = Tool("🦠", "Miraculous Virus")
    
    init(_ gender: Gender,_ age: Age, _ icon: String, _ role: String) {
        super.init(Medical.getNewID(), gender, age, icon, role)
        // Malus = Kinetic, Bonus = Biologic
        self.fightSet.biologic.defense *= Modifier.bonus()
        self.fightSet.biologic.attack *= Modifier.bonus()
        self.fightSet.kinetic.defense *= Modifier.malus()
        self.fightSet.kinetic.attack *= Modifier.malus()
        self.fightSet.thermic.defense *= Modifier.same()
        self.fightSet.thermic.attack *= Modifier.same()
    }
    
    static var All: [Toon] = [Medical]()
    static func createAll(){
        var toon: (pic: String, title: String)
        var tool: (pic: String, name: String)
        for age in Age.allCases {
            for gender in Gender.allCases {
                switch (age, gender) {
                case (.isJunior, .isMan):
                    toon = ("👨‍🎓", "PostGraduate") ; tool = ("💉", "Stiring Syringe")
                case (.isJunior, .isWoman):
                    toon = ("👩‍🎓", "PostGraduate") ; tool = ("🍿", "Poisoned Popcorn")
                case (.isAdult, .isMan):
                    toon = ("👨‍⚕️", "Biologist") ; tool = ("🩺", "Strangling Stethoscope")
                case (.isAdult, .isWoman):
                    toon = ("👩‍⚕️", "Biologist") ; tool = ("🔬", "Mischief Microscope")
                case (.isSenior, .isMan):
                    toon = ("👨‍🔬", "NobelPrice") ; tool = ("🧪", "Secret Substance")
                case (.isSenior, .isWoman):
                    toon = ("👩‍🔬", "NobelPrice") ; tool = ("🧬", "Dna Denaturator")
            }
            let newMedical: Medical = Medical(gender, age, toon.pic, toon.title)
            newMedical.tool = BiologicWeapon(age, tool.pic, tool.name)
            All.append(newMedical)
            }
        }
    }
}

// MARK: Daughter : Military
final class Military: Toon {
    
    private static var newID: Int = 0
    private static func getNewID() -> Int {
        Military.newID += 1
        return Military.newID
    }
    
    init(_ gender: Gender,_ age: Age, _ icon: String, _ role: String) {
        super.init(Military.getNewID(), gender, age, icon, role)
        // Malus = Biologic, Bonus = Thermic
        self.fightSet.biologic.defense *= Modifier.malus()
        self.fightSet.biologic.attack *= Modifier.malus()
        self.fightSet.kinetic.defense *= Modifier.same()
        self.fightSet.kinetic.attack *= Modifier.same()
        self.fightSet.thermic.defense *= Modifier.bonus()
        self.fightSet.thermic.attack *= Modifier.bonus()
    }
    
    static var All: [Toon] = [Military]()
    static func createAll(){
        var toon: (pic: String, title: String)
        var tool: (pic: String, name: String)
        for age in Age.allCases {
            for gender in Gender.allCases {
                switch (age, gender) {
                case (.isJunior, .isMan):
                    toon = ("👨‍🚒", "FireFighter") ; tool = ("🪓", "Hashing Hatchet")
                case (.isJunior, .isWoman):
                    toon = ("👩‍🚒", "FireFighter") ; tool = ("🧨", "Dynamic Dynamite")
                case (.isAdult, .isMan):
                    toon = ("👮‍♂️", "HighCommander") ; tool = ("🔫", "GreenSight Gun")
                case (.isAdult, .isWoman):
                    toon = ("👮‍♀️", "HighCommander") ; tool = ("💣", "Dirty Detonator")
                case (.isSenior, .isMan):
                    toon = ("🕵️‍♂️", "SecretService") ; tool = ("🌂", "Bulgarian Umbrella")
                case (.isSenior, .isWoman):
                    toon = ("🕵️‍♀️", "SecretService") ; tool = ("🕳", "Wicked Weapon")
            }
            let newMilitary: Military = Military(gender, age, toon.pic, toon.title)
                newMilitary.tool = ThermicWeapon(age, tool.pic, tool.name)
            All.append(newMilitary)
            }
        }
    }
}
