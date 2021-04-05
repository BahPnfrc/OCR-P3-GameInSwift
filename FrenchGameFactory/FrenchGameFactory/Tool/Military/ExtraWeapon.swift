//
//  BonusWeapon.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 05/04/2021.
//

import Foundation

final class ExtraWeapon: Weapon {
    
    enum BonusType { case isBonus, isMalus }
    private static let sickPercentPenalty: Int = 10
    private static let sickMultiplicator: Double = Double(sickPercentPenalty) / 100
    
    private let bonusType: BonusType
    
    init(withPic pic: String, withName name: String, withType type: BonusType) {
        self.bonusType = type
        super.init(withPic: pic, withName: name)
        self.isUpdated = true
        
        switch self.bonusType {
        case .isBonus:
            self.damageSet.biologic.updated = Setting.Weapon.extraWeaponBiologicBonus
        case .isMalus:
            self.damageSet.biologic.updated = Setting.Weapon.extraWeaponBiologicMalus
        }
    }
    
    // MARK: Private internal actions
    private static var weaponSaver: [(toon: Toon, previousWeapon: Weapon)] = []
    private static func toonGetNewWeapon(forToon toon:Toon, fromBox box:String) {
        weaponSaver.append((toon, toon.weapon!))
        toon.weapon = getRandomWeapon()
        let message: String = "\(toon.getPicWithName()) just had a \(toon.weapon!.getPicWithName()) of the \(box) :"
        let weapon: ExtraWeapon = toon.weapon as! ExtraWeapon
        let help: String = weapon.bonusType == .isBonus ?
            "The \(toon.weapon!.getPicWithName()) takes \(sickPercentPenalty)% hitpoints each round until medicine is given" :
            "This \(toon.weapon!.getPicWithName()) lost some of its venomoussness since last full moon..."
        Console.write(1, 1, "\(message)\n\(help)", 1)
    }
    private static func toonGetPreviousWeapon() {
        for save in weaponSaver {
            save.toon.weapon = save.previousWeapon
            let toon = save.toon.getPicWithName() ; let weapon = save.toon.weapon!.getPicWithName()
            Console.write(1, 1, "\(toon) just got back \(save.toon.getHisOrHer())\(weapon)", 1)
        }
    }
    
    private static func getRandomWeapon() -> ExtraWeapon {
        var extraWeapons: [ExtraWeapon] = []
        extraWeapons.append(ExtraWeapon(withPic: "🦠", withName: "Vicious Virus", withType: .isBonus))
        extraWeapons.append(ExtraWeapon(withPic: "🍄", withName: "FullMoon 'Shroom", withType: .isMalus))
        return extraWeapons.randomElement()!
    }
    
    // MARK: Public static actions
    static func getExtraWeapon(forToon toon: Toon, forced: Bool = false) -> Bool {
        
        let matchRange: ClosedRange = 0...5
        let matchValue: Int = matchRange.randomElement()!
        if forced == false && !matchValue.isMultiple(of: 2) { return false }
    
        let box: String = "🎁,📦,🧺".components(separatedBy: ",").randomElement()!
        Console.write(1, 1, """
            Oh ! A mysterious \(box) just came out from a ☁️...
            It might contains a better weapon 👍 or a weaker one 👎...
            1. 🔓 I want to open the \(box) and try its ✨mysterious✨ weapon
            2. 🔒 Naaaah, I'm all right with my \(toon.weapon!.getPicWithName())
            """, 0)
        let openTheBoxPrompt = Console.getIntInput(fromTo: 1...2)
        if openTheBoxPrompt == 2 { return false }
        
        toonGetNewWeapon(forToon: toon, fromBox: box)
        return true
    }
    static func restoreAllWeapons() {
        toonGetPreviousWeapon()
    }
    static func applySickness(inGame game: Game) {
        let players: [Player] = [game.attackingPlayer, game.defendingPlayer]
        for player in players {
            for toon in player.toons {
                if toon.lifeSet.isSick {
                    let toonHitpoints: Int = toon.lifeSet.hitpoints
                    let damage: Double = Double(toonHitpoints) * sickMultiplicator
                    toon.lifeSet.hitpoints -= Int(damage)
                    toon.statSet.totalDamage.received += Int(damage)
                }
            }
        }
    }
    
}
