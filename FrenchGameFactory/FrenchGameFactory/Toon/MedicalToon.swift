//
//  Medical.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 20/03/2021.
//

import Foundation

// MARK: Daughter : Medical
final class MedicalToon: Toon {
     
    private static var newID: Int = 0
    private static func getNewID() -> Int {
        MedicalToon.newID += 1
        return MedicalToon.newID
    }
    
    var medicalPack: [Medicine] = Medicine.getMedicalPack()
    
    init(withGender gender: Gender,
         withAge age: Age,
         withPic pic: String,
         withTitle title: String) {
        
        super.init(
            withID: MedicalToon.getNewID(),
            withGender: gender,
            withAge: age,
            withPic: pic,
            withTitle: title)
        
        // Malus = Kinetic, Bonus = Biologic
        // Malus = c/ Engineer, Bonus c/ Military
        self.fightSet.biologic.defense *= ToonModifier.bonus()
        self.fightSet.biologic.attack *= ToonModifier.bonus()
        self.fightSet.kinetic.defense *= ToonModifier.malus()
        self.fightSet.kinetic.attack *= ToonModifier.malus()
        self.fightSet.thermic.defense *= ToonModifier.same()
        self.fightSet.thermic.attack *= ToonModifier.same()
    }
    
    static var All: [Toon] = [MedicalToon]()
    static func createAll(){
        var toon: (pic: String, title: String)
        var weapon: (pic: String, name: String)
        for age in Age.allCases {
            for gender in Gender.allCases {
                switch (age, gender) {
                case (.isJunior, .isMan):
                    toon = ("👨‍🎓", "Post Graduate") ; weapon = ("💉", "Stirring Syringe")
                case (.isJunior, .isWoman):
                    toon = ("👩‍🎓", "Post Graduate") ; weapon = ("🍿", "Poisoned Popcorn")
                case (.isAdult, .isMan):
                    toon = ("👨‍⚕️", "Biologist") ; weapon = ("🩺", "Strangling Stethoscope")
                case (.isAdult, .isWoman):
                    toon = ("👩‍⚕️", "Biologist") ; weapon = ("🔬", "Mischief Microscope")
                case (.isSenior, .isMan):
                    toon = ("👨‍🔬", "Nobel Price") ; weapon = ("🧪", "Secret Substance")
                case (.isSenior, .isWoman):
                    toon = ("👩‍🔬", "Nobel Price") ; weapon = ("🧫", "Pinky Plague")
            }
            let newMedical: MedicalToon = MedicalToon(
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
