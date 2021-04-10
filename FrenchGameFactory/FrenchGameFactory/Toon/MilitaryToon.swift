//
//  Military.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 20/03/2021.
//

import Foundation

// MARK: Daughter : Military
final class MilitaryToon: Toon {
    
    private static var newID: Int = 0
    private static func getNewID() -> Int {
        MilitaryToon.newID += 1
        return MilitaryToon.newID
    }
    
    init(withGender gender: Gender,
         withAge age: Age,
         withPic pic: String,
         withTitle title: String) {
        
        super.init(
            withID: MilitaryToon.getNewID(),
            withGender: gender,
            withAge: age,
            withPic: pic,
            withTitle: title)
        
        // Malus = Biologic, Bonus = Thermic
        // Malus = c/ Medical, Bonus = c/ Engineer
        self.fightSet.biologic.defense *= ToonModifier.malus()
        self.fightSet.biologic.attack *= ToonModifier.malus()
        self.fightSet.kinetic.defense *= ToonModifier.same()
        self.fightSet.kinetic.attack *= ToonModifier.same()
        self.fightSet.thermic.defense *= ToonModifier.bonus()
        self.fightSet.thermic.attack *= ToonModifier.bonus()
    }
    
    static var All: [Toon] = [MilitaryToon]()
    static func createAll(){
        var toon: (pic: String, title: String)
        var weapon: (pic: String, name: String)
        for age in Age.allCases {
            for gender in Gender.allCases {
                switch (age, gender) {
                case (.isJunior, .isMan):
                    toon = ("👨‍🚒", "Fire Fighter") ; weapon = ("🪓", "Hashing Hatchet")
                case (.isJunior, .isWoman):
                    toon = ("👩‍🚒", "Fire Fighter") ; weapon = ("🧨", "Dynamic Dynamite")
                case (.isAdult, .isMan):
                    toon = ("👮‍♂️", "High Commander") ; weapon = ("🔫", "GreenPun Gun")
                case (.isAdult, .isWoman):
                    toon = ("👮‍♀️", "High Commander") ; weapon = ("💣", "Dirty Detonator")
                case (.isSenior, .isMan):
                    toon = ("🕵️‍♂️", "Secret Service") ; weapon = ("🌂", "Bulgarian Umbrella")
                case (.isSenior, .isWoman):
                    toon = ("🕵️‍♀️", "Secret Service") ; weapon = ("🕳", "Wicked Weapon")
            }
            let newMilitary: MilitaryToon = MilitaryToon(
                withGender: gender,
                withAge: age,
                withPic: toon.pic,
                withTitle: toon.title)
            newMilitary.weapon = ThermicWeapon(
                withGender: gender,
                withAge: age,
                withPic: weapon.pic,
                withName: weapon.name)
            All.append(newMilitary)
            }
        }
    }
}
