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
