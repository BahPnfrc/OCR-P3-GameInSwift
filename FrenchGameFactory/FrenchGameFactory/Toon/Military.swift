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
    
    init(withGender gender: Gender,
         withAge age: Age,
         withPic pic: String,
         withTitle title: String) {
        
        super.init(
            withID: Military.getNewID(),
            withGender: gender,
            withAge: age,
            withPic: pic,
            withTitle: title)
        
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
            let newMilitary: Military = Military(
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
