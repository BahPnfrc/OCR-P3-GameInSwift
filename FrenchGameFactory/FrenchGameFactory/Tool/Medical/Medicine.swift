//
//  Medicine.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 21/03/2021.
//

import Foundation

enum MedicineType { case isLight, isMedium, isHeavy }

final class Medicine : Tool {
    
    var promptID: Int = 0
    let type: MedicineType
    var about: String = ""
    var left: Int
    
    var factor: Double?
    
    init(withPic pic: String,
         withName name: String,
         withType type: MedicineType,
         withLeft left: Int,
         withAbout about: String) {
        
        self.type = type
        self.left = left
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
                withLeft: 1,
                withAbout: "it restores receiver health to 70%")
        let medium: Medicine = Medicine(
                withPic: "💊",
                withName: "Precision Pill",
                withType: .isMedium,
                withLeft: 1,
                withAbout: "it restores receiver health to 90%")
        let heavy: Medicine = Medicine(
                withPic: "🧬",
                withName: "Dna Denaturator",
                withType: .isHeavy,
                withLeft: 1,
                withAbout: "it restores all toons health to 50%")
        return [light, medium, heavy]
    }

    func useHeavyMedicine(medicine: Medicine, onPlayer player: Player) {
        let expectedHitpoints: Int = Setting.Toon.defaultLifeSet.hitpoints * 5 / 10 // 50%
        for toon in player.toons { _ = _restoreHitpoints(ofToon: toon, to: expectedHitpoints) }
        Console.write(1, 1, "Team of \(player.name) experienced the \(medicine.getPicWithName()) and it felt amazing 👍", 1)
        medicine.left -= 1
    }
    func useMediumOrLightMedicine(medicine: Medicine, onToon toon: Toon) {
        // Double cast variable + cast
        factor = medicine.type == .isMedium ? (9 / 10) : (7 / 10)
        //guard let localFactor = factor! else { return }
        let expectedHitpoints: Int = Setting.Toon.defaultLifeSet.hitpoints * Int(factor!) // 50%
        if (_restoreHitpoints(ofToon: toon, to: expectedHitpoints)) == true {
            Console.write(1, 1, "\(toon.getPicWithName()) just had a \(medicine.getPicWithName()) and feels much better 💪", 1)
        } else { Console.write(1, 1, "\(toon.getPicWithName()) just had a \(medicine.getPicWithName()) with no effect 👎", 1) }
        medicine.left -= 1
    }
    private func _restoreHitpoints(ofToon toon: Toon, to expectedHitpoints: Int) -> Bool {
        let currentHitpoints: Int = toon.lifeSet.hitpoints
        if currentHitpoints < expectedHitpoints {
            toon.lifeSet.hitpoints = expectedHitpoints
            return true
        } else { return false }
    }
    
}
