//
//  Engineer.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 20/03/2021.
//

import Foundation

// MARK: Daughter : Engineer
final class Engineer: Toon {
    
    private static var newID: Int = 0
    private static func getNewID() -> Int {
        Engineer.newID += 1
        return Engineer.newID
    }

    init(withGender gender: Gender,
         withAge age: Age,
         withPic pic: String,
         withTitle title: String) {
        
        super.init(
            withID: Engineer.getNewID(),
            withGender: gender,
            withAge: age,
            withPic: pic,
            withTitle: title)
        
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
        var weapon: (pic: String, name: String)
        for age in Age.allCases {
            for gender in Gender.allCases {
                switch (age, gender) {
                case (.isJunior, .isMan):
                    toon = ("👨‍🔧", "Young Meccano") ; weapon = ("🔧", "BloodStench Wrench")
                case (.isJunior, .isWoman):
                    toon = ("👩‍🔧,", "Young Meccano") ; weapon = ("🔩", "ChewThrough Screw")
                case (.isAdult, .isMan):
                    toon = ("👨‍💻", "Apple Coder") ; weapon = ("💻", "MacBook Pro")
                case (.isAdult, .isWoman):
                    toon = ("👩‍💻", "Apple Coder") ; weapon = ("🖥", "iMac Pro")
                case (.isSenior, .isMan):
                    toon = ("👨‍💼", "Emeritus") ; weapon = ("📡", "Parabellum Parrabolla")
                case (.isSenior, .isWoman):
                    toon = ("👩‍💼", "Emeritus") ; weapon = ("🦾", "Bionic Beef")
            }
            let newEngineer: Engineer = Engineer(
                withGender: gender,
                withAge: age,
                withPic: toon.pic,
                withTitle: toon.title)
            newEngineer.weapon = KineticWeapon(
                withGender: gender,
                withAge: age,
                withPic: weapon.pic,
                withName: weapon.name)
            All.append(newEngineer)
            }
        }
    }
}
