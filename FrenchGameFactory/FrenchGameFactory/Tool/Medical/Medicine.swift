//
//  Medicine.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 21/03/2021.
//

import Foundation

enum MedicineType { case isLight, iSMedium, isHeavy }

final class Medicine : Tool {
    
    var promptID: Int = 0
    let type: MedicineType
    var about: String = ""
    var usage: (
        wasUsed: Int,
        maxUse: Int)
    
    init(withPic pic: String,
         withName name: String,
         withType type: MedicineType,
         withUsage usage: (Int, Int),
         withAbout about: String) {
        
        self.type = type
        self.usage = usage
        self.about = about
        super.init(
            withPic: pic,
            withName: name)
    }
    
    static func getMedicalPack() -> [Medicine] {
        
        let light: Medicine = Medicine(
                withPic: "🩹",
                withName: "Savage Bandage",
                withType: .isLight,
                withUsage: (0, 2),
                withAbout: "it restores receiver health to 70%")
        let medium: Medicine = Medicine(
                withPic: "💊",
                withName: "Precision Pill",
                withType: .iSMedium,
                withUsage: (0, 1),
                withAbout: "it restores receiver health to 90%")
        let heavy: Medicine = Medicine(
                withPic: "🧬",
                withName: "Dna Denaturator",
                withType: .isHeavy,
                withUsage: (0, 1),
                withAbout: "it restores all toons health to 50%")
        return [light, medium, heavy]
    }
    
}
