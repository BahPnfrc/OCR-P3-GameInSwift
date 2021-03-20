//
//  Military.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 20/03/2021.
//

import Foundation

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
