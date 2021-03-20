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
    
    let lightMedicine = Tool("🩹", "Savage Bandage")
    let mediumMedicine = Tool("💊", "Precision Pill")
    let heavyMedicine = Tool("🦠", "Miraculous Virus")
    
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
        var tool: (pic: String, name: String)
        for age in Age.allCases {
            for gender in Gender.allCases {
                switch (age, gender) {
                case (.isJunior, .isMan):
                    toon = ("👨‍🎓", "PostGraduate") ; tool = ("💉", "Stiring Syringe")
                case (.isJunior, .isWoman):
                    toon = ("👩‍🎓", "PostGraduate") ; tool = ("🍿", "Poisoned Popcorn")
                case (.isAdult, .isMan):
                    toon = ("👨‍⚕️", "Biologist") ; tool = ("🩺", "Strangling Stethoscope")
                case (.isAdult, .isWoman):
                    toon = ("👩‍⚕️", "Biologist") ; tool = ("🔬", "Mischief Microscope")
                case (.isSenior, .isMan):
                    toon = ("👨‍🔬", "NobelPrice") ; tool = ("🧪", "Secret Substance")
                case (.isSenior, .isWoman):
                    toon = ("👩‍🔬", "NobelPrice") ; tool = ("🧬", "Dna Denaturator")
            }
            let newMedical: Medical = Medical(gender, age, toon.pic, toon.title)
            newMedical.tool = BiologicWeapon(age, tool.pic, tool.name)
            All.append(newMedical)
            }
        }
    }
}
