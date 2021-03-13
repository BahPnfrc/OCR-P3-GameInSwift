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
        strenght: Double,
        accuracy: Double,
        experience: Double,
        agility: Double)
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
enum Gender: CaseIterable { case isMan, isWomen }
enum Age: CaseIterable { case isJunior, isAdult, isSenior }

// MARK: Mother class
class Toon: LifeSet, SkillSet, FightSet {
    
    static var All = [Toon]()

    var gender: Gender
    var age: Age
    
    var name: String?
    var picture: String
    var job: String
    func getFullName() -> String{
        guard let name = self.name else {
            return self.picture + " " + self.job
        }
        return self.picture + " " + self.job + " " + name
    }
    
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
    
    init(_ gender: Gender, _ age: Age, _ icon: String, _ role: String ){
        
        self.gender = gender
        self.age = age
        self.picture = icon
        self.job = role
        
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

// MARK: Daughter : Engineer
class Engineer: Toon {
    override init(_ gender: Gender,_ age: Age, _ icon: String, _ role: String) {
        super.init(gender, age, icon, role)
        // Malus = Thermic, Bonus = Kinetic
        self.fightSet.biologic.defense *= Modifier.same()
        self.fightSet.biologic.attack *= Modifier.same()
        self.fightSet.kinetic.defense *= Modifier.bonus()
        self.fightSet.kinetic.attack *= Modifier.bonus()
        self.fightSet.thermic.defense *= Modifier.malus()
        self.fightSet.thermic.attack *= Modifier.malus()
    }
    
    static func createAll(){
        var toon: (pic: String, job: String)
        var basic: (pic: String, name: String)
        var updated: (pic: String, name: String)
        for age in Age.allCases {
            for gender in Gender.allCases {
                switch age {
                case .isJunior:
                    toon = (gender == Gender.isMan ? "👨‍🔧" : "👩‍🔧",  "YoungMeccano")
                    basic = ("🔧", "French Wrench")
                    updated = ("⚙️", "Chew Screw")
                case .isAdult:
                    toon = (gender == Gender.isMan ? "👨‍💻" : "👩‍💻", "MachineCoder")
                    basic = ("💻", "MacPuke Pro") ;
                    updated = ("🖥", "iSmack Pro")
                case .isSenior:
                    toon = (gender == Gender.isMan ? "👨‍💼" : "👩‍💼", "EmeritusProfessor")
                    basic = ("📡", "Paralysing Parrabolla")
                    updated = ("🦾", "Bionic Beef")
                }
                let newEngineer: Engineer = Engineer(gender, age, toon.pic, toon.job)
                newEngineer.tool = KineticWeapon(age, basic.pic, basic.name, updated.pic, updated.name)
                Toon.All.append(newEngineer)
            }
        }
    }
}

// MARK: Daughter : Medical
class Medical: Toon {
    override init(_ gender: Gender,_ age: Age, _ icon: String, _ role: String) {
        super.init(gender, age, icon, role)
        // Malus = Kinetic, Bonus = Biologic
        self.fightSet.biologic.defense *= Modifier.bonus()
        self.fightSet.biologic.attack *= Modifier.bonus()
        self.fightSet.kinetic.defense *= Modifier.malus()
        self.fightSet.kinetic.attack *= Modifier.malus()
        self.fightSet.thermic.defense *= Modifier.same()
        self.fightSet.thermic.attack *= Modifier.same()
    }
    
    static func createAll(){
        var toon: (pic: String, job: String)
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
                let newEngineer: Engineer = Engineer(gender, age, toon.pic, toon.job)
                newEngineer.tool = BiologicWeapon(age, basic.pic, basic.name, updated.pic, updated.name)
                Toon.All.append(newEngineer)
            }
        }
    }
}

// MARK: Daughter : Military
class Military: Toon {
    override init(_ gender: Gender,_ age: Age, _ icon: String, _ role: String) {
        super.init(gender, age, icon, role)
        // Malus = Biologic, Bonus = Thermic
        self.fightSet.biologic.defense *= Modifier.malus()
        self.fightSet.biologic.attack *= Modifier.malus()
        self.fightSet.kinetic.defense *= Modifier.same()
        self.fightSet.kinetic.attack *= Modifier.same()
        self.fightSet.thermic.defense *= Modifier.bonus()
        self.fightSet.thermic.attack *= Modifier.bonus()
    }
    
    static func createAll(){
        var toon: (pic: String, job: String)
        var basic: (pic: String, name: String)
        var updated: (pic: String, name: String)
        for age in Age.allCases {
            for gender in Gender.allCases {
                switch age {
                case .isJunior:
                    toon = (gender == Gender.isMan ? "👨‍🚒" : "👩‍🚒",  "FireFighter")
                    basic = ("🧯", "Poisoned Popcorn")
                    updated = ("🧨", "Dynamic Dynamite")
                case .isAdult:
                    toon = (gender == Gender.isMan ? "👮‍♂️" : "👮‍♀️", "HighCommander")
                    basic = ("🔫", "Green Gun") ;
                    updated = ("💣", "Dirty Detonator")
                case .isSenior:
                    toon = (gender == Gender.isMan ? "🕵️‍♂️" : "🕵️‍♀️", "SecretService")
                    basic = ("🌂", "Bulgarian Umbrella")
                    updated = ("🕳", "Wicked Weapon")
                }
                let newEngineer: Engineer = Engineer(gender, age, toon.pic, toon.job)
                newEngineer.tool = ThermicWeapon(age, basic.pic, basic.name, updated.pic, updated.name)
                Toon.All.append(newEngineer)
            }
        }
    }
}
