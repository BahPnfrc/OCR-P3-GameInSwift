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
        experience: Double, // Must balance out with agility
        agility: Double) // Must balance out with experience
        {get}
}
extension SkillSet {
    func getStrenght() -> Double {return skillSet.strenght}
    func getAccuracy() -> Double {return skillSet.accuracy}
    func getExperience() -> Double {return skillSet.experience}
    func getAgility() -> Double {return skillSet.agility}
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
}

protocol StatSet {
    // Stat
}

// MARK: Enumations
enum Gender: String, CaseIterable { case isMan = "man", isWomen = "women" }
enum Age: String, CaseIterable { case isJunior = "mid 30'", isAdult = "mid 40'", isSenior = "mid 50'" }

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
    lazy var lifeSet: (
        hitpoints: Int,
        isSick: Bool)
        = Toon.defLife
    
    private static var defSkill: Double = 1.0
    lazy var skillSet: (
        strenght: Double,
        accuracy: Double,
        experience: Double,
        agility: Double)
        = (Toon.defSkill,
           Toon.defSkill,
           Toon.defSkill,
           Toon.defSkill)
    
    private static var defFight: (Double, Double) = (1.0, 1.0)
    lazy var fightSet: (
        biologic: (defense: Double, attack: Double),
        kinetic: (defense: Double, attack: Double),
        thermic: (defense: Double, attack: Double))
        = ((Toon.defFight),
           (Toon.defFight),
           (Toon.defFight))
    
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
        case .isWomen:
            self.skillSet.strenght *= Modifier.malus()
            self.skillSet.accuracy *= Modifier.bonus()
        // Changing property according to age
        switch self.age {
        case .isJunior:
            self.skillSet.experience *= Modifier.malus()
            self.skillSet.agility *= Modifier.bonus()
        case .isAdult:
            self.skillSet.experience *= Modifier.same()
            self.skillSet.agility *= Modifier.same()
        case .isSenior:
            self.skillSet.experience *= Modifier.bonus()
            self.skillSet.agility *= Modifier.malus()
            }
        }
    }
}

// MARK: Mother extension
extension Toon {
    func getPossesive() -> String {
        gender == .isMan ? "his " : "her "
    }
    func getAgeAndGender() -> String {
        return gender.rawValue + " in " + getPossesive() + age.rawValue
    }
    func getFullName() -> String {
        guard let name = name else {
            return  title + " " + pic
        }
        return title + " " + name + " " + pic
    }
    func getPresentation() -> String {
        let name: String = String(ID) + ". " +  getFullName()
        let ageAndGender: String = "A " + getAgeAndGender()
        let tool: String = "armed with " + getPossesive() + self.tool!.getPicWithName()
        return name + " : " + ageAndGender + ", " + tool
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
        var basic: (pic: String, name: String)
        var updated: (pic: String, name: String)
        for age in Age.allCases {
            for gender in Gender.allCases {
                switch age {
                case .isJunior:
                    toon = (gender == Gender.isMan ? "👨‍🔧" : "👩‍🔧",  "YoungMeccano")
                    basic = ("🔧", "BloodStench Wrench")
                    updated = ("🔩", "ChewThrough Screw")
                case .isAdult:
                    toon = (gender == Gender.isMan ? "👨‍💻" : "👩‍💻", "MachineCoder")
                    basic = ("💻", "MacPuke Pro") ;
                    updated = ("🖥", "iSmack Pro")
                case .isSenior:
                    toon = (gender == Gender.isMan ? "👨‍💼" : "👩‍💼", "EmeritusProfessor")
                    basic = ("📡", "Parabellum Parrabolla")
                    updated = ("🦾", "Bionic Beef")
                }
                let newEngineer: Engineer = Engineer(gender, age, toon.pic, toon.title)
                newEngineer.tool = KineticWeapon(age, basic.pic, basic.name, updated.pic, updated.name)
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
    
    let medecineTool = Tool("🩹", "SavageBandage", "💊", "HealPill")
    
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
        var basic: (pic: String, name: String)
        var updated: (pic: String, name: String)
        for age in Age.allCases {
            for gender in Gender.allCases {
                switch age {
                case .isJunior:
                    toon = (gender == Gender.isMan ? "👨‍🎓" : "👩‍🎓",  "PostGraduate")
                    basic = ("🍿", "Poisoned Popcorn")
                    updated = ("💉", "Singing Syringe")
                case .isAdult:
                    toon = (gender == Gender.isMan ? "👨‍⚕️" : "👩‍⚕️", "Biologist")
                    basic = ("🩺", "Strangling Stethoscope") ;
                    updated = ("🔬", "Mischief Microscope")
                case .isSenior:
                    toon = (gender == Gender.isMan ? "👨‍🔬" : "👩‍🔬", "NobelPrice")
                    basic = ("🧪", "Secret Substance")
                    updated = ("🧬", "Dna Denaturator")
                }
                let newMedical: Medical = Medical(gender, age, toon.pic, toon.title)
                newMedical.tool = BiologicWeapon(age, basic.pic, basic.name, updated.pic, updated.name)
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
        var basic: (pic: String, name: String)
        var updated: (pic: String, name: String)
        for age in Age.allCases {
            for gender in Gender.allCases {
                switch age {
                case .isJunior:
                    toon = (gender == Gender.isMan ? "👨‍🚒" : "👩‍🚒",  "FireFighter")
                    basic = ("🪓", "Hashing Hatchet")
                    updated = ("🧨", "Dynamic Dynamite")
                case .isAdult:
                    toon = (gender == Gender.isMan ? "👮‍♂️" : "👮‍♀️", "HighCommander")
                    basic = ("🔫", "GreenSight Gun") ;
                    updated = ("💣", "Dirty Detonator")
                case .isSenior:
                    toon = (gender == Gender.isMan ? "🕵️‍♂️" : "🕵️‍♀️", "SecretService")
                    basic = ("🌂", "Bulgarian Umbrella")
                    updated = ("🕳", "Wicked Weapon")
                }
                let newMilitary: Military = Military(gender, age, toon.pic, toon.title)
                newMilitary.tool = ThermicWeapon(age, basic.pic, basic.name, updated.pic, updated.name)
                All.append(newMilitary)
            }
        }
    }
}
