//
//  Medical.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 20/03/2021.
//

import Foundation

// MARK: Daughter : Medical
final class Medical: Toon {
     
    private static var newID: Int = 0
    private static func getNewID() -> Int {
        Medical.newID += 1
        return Medical.newID
    }
    
    var medicalPack: [Medicine] = Medicine.getMedicalPack()
    
    init(withGender gender: Gender,
         withAge age: Age,
         withPic pic: String,
         withTitle title: String) {
        
        super.init(
            withID: Medical.getNewID(),
            withGender: gender,
            withAge: age,
            withPic: pic,
            withTitle: title)
        
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
        var weapon: (pic: String, name: String)
        for age in Age.allCases {
            for gender in Gender.allCases {
                switch (age, gender) {
                case (.isJunior, .isMan):
                    toon = ("👨‍🎓", "Post Graduate") ; weapon = ("💉", "Stiring Syringe")
                case (.isJunior, .isWoman):
                    toon = ("👩‍🎓", "Post Graduate") ; weapon = ("🍿", "Poisoned Popcorn")
                case (.isAdult, .isMan):
                    toon = ("👨‍⚕️", "Biologist") ; weapon = ("🩺", "Strangling Stethoscope")
                case (.isAdult, .isWoman):
                    toon = ("👩‍⚕️", "Biologist") ; weapon = ("🔬", "Mischief Microscope")
                case (.isSenior, .isMan):
                    toon = ("👨‍🔬", "Nobel Price") ; weapon = ("🧪", "Secret Substance")
                case (.isSenior, .isWoman):
                    toon = ("👩‍🔬", "Nobel Price") ; weapon = ("🧫", "Petri Plague")
            }
            let newMedical: Medical = Medical(
                withGender: gender,
                withAge: age,
                withPic: toon.pic,
                withTitle: toon.title)
            newMedical.weapon = BiologicWeapon(
                withGender: gender,
                withAge: age,
                withPic: weapon.pic,
                withName: weapon.name)
            All.append(newMedical)
            }
        }
    }
}
