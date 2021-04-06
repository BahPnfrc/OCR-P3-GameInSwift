//
//  Engineer.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 20/03/2021.
//

import Foundation

// MARK: Daughter : Engineer
final class EngineerToon: Toon {
    
    private static var newID: Int = 0
    private static func getNewID() -> Int {
        EngineerToon.newID += 1
        return EngineerToon.newID
    }

    init(withGender gender: Gender,
         withAge age: Age,
         withPic pic: String,
         withTitle title: String) {
        
        super.init(
            withID: EngineerToon.getNewID(),
            withGender: gender,
            withAge: age,
            withPic: pic,
            withTitle: title)
        
        // Malus = Thermic, Bonus = Kinetic
        self.fightSet.biologic.defense *= ToonModifier.same()
        self.fightSet.biologic.attack *= ToonModifier.same()
        self.fightSet.kinetic.defense *= ToonModifier.bonus()
        self.fightSet.kinetic.attack *= ToonModifier.bonus()
        self.fightSet.thermic.defense *= ToonModifier.malus()
        self.fightSet.thermic.attack *= ToonModifier.malus()
    }
    
    static var All: [Toon] = [EngineerToon]()
    static func createAll(){
        var toon: (pic: String, title: String)
        var weapon: (pic: String, name: String)
        for age in Age.allCases {
            for gender in Gender.allCases {
                switch (age, gender) {
                case (.isJunior, .isMan):
                    toon = ("👨‍🔧", "Young Meccano") ; weapon = ("🔧", "BloodStench Wrench")
                case (.isJunior, .isWoman):
                    toon = ("👩‍🔧", "Young Meccano") ; weapon = ("🔩", "ChewThrough Screw")
                case (.isAdult, .isMan):
                    toon = ("👨‍💻", "Apple Coder") ; weapon = ("💻", "MacBook Pro")
                case (.isAdult, .isWoman):
                    toon = ("👩‍💻", "Apple Coder") ; weapon = ("🖥", "iMac Pro")
                case (.isSenior, .isMan):
                    toon = ("👨‍💼", "Emeritus Pr.") ; weapon = ("📡", "Parabellum Parrabolla")
                case (.isSenior, .isWoman):
                    toon = ("👩‍💼", "Emeritus Pr.") ; weapon = ("🦾", "Bionic Beef")
            }
            let newEngineer: EngineerToon = EngineerToon(
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
