//
//  Medicine.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 21/03/2021.
//

import Foundation

enum MedicineType { case isLight, isMedium, isHeavy }

class Medicine : Tool {
    
    var promptID: Int = 0
    let type: MedicineType
    let factor: Double
    var about: String = ""
    var left: Int
    
    init(withPic pic: String,
         withName name: String,
         withType type: MedicineType,
         withFactor factor: Double,
         withLeft left: Int,
         withAbout about: String) {
        
        self.type = type
        self.factor = factor
        self.left = left
        self.about = about
        super.init(
            withPic: pic,
            withName: name)
    }
    
    func restoreHitpointsWithStats(ofToon toon: Toon, to expectedHitpoints: Int) -> Int {
        let currentHitpoints: Int = toon.lifeSet.hitpoints
        if currentHitpoints < expectedHitpoints {
            let restoredHitpoints: Int = expectedHitpoints - currentHitpoints
            toon.statSet.medicine.received += restoredHitpoints // #STAT
            toon.lifeSet.hitpoints += restoredHitpoints
            return restoredHitpoints
        } else { return 0 }
    }
    
    static func getMedicalPack() -> [Medicine] {
        
        let light: SingleUseMedicine = SingleUseMedicine(
                withPic: "🩹",
                withName: "Savage Bandage",
                withType: .isLight,
                withFactor: 0.7,
                withLeft: 1,
            withAbout: "it restores receiver health to 70%".withNum())
        let medium: SingleUseMedicine = SingleUseMedicine(
                withPic: "💊",
                withName: "Precision Pill",
                withType: .isMedium,
                withFactor: 0.9,
                withLeft: 1,
                withAbout: "it restores receiver health to 90%".withNum())
        let heavy: TeamUseMedicine = TeamUseMedicine(
                withPic: "🧬",
                withName: "Dna Denaturator",
                withType: .isHeavy,
                withFactor: 0.5,
                withLeft: 1,
                withAbout: "it restores all toons health to 50%".withNum())
        return [light, medium, heavy]
    }
    
}
