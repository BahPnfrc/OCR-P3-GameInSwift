//
//  ExtraWeapon.swift
//  FrenchGameFactory
//
//  Created by Pierre-Alexandre on 05/04/2021.
//

import Foundation

final class ExtraWeapon: Weapon {
    
    enum ExtraWeaponType { case isBonusDisease, isMalus }
    private static let sickPercentPenalty: Int = 10
    private static let sickMultiplicator: Double = Double(sickPercentPenalty) / 100
    
    let type: ExtraWeaponType
    
    init(withPic pic: String, withName name: String, withType type: ExtraWeaponType) {
        self.type = type
        super.init(withPic: pic, withName: name)
        self.isUpdated = true
        
        switch self.type {
        case .isBonusDisease:
            (damageSet.biologic.updated,
             damageSet.kinetic.updated,
             damageSet.thermic.updated)
                = Setting.ExtraWeapon.updatedDamageSetWithBonus
        case .isMalus:
            (damageSet.biologic.updated,
             damageSet.kinetic.updated,
             damageSet.thermic.updated)
                = Setting.ExtraWeapon.updatedDamageSetwithMalus
        }
    }
    
    // MARK: Public static actions
    static func extraWeaponAttempt(forToon toon: Toon) {
        // A - Check if attempt is valid
        guard Setting.ExtraWeapon.isForcedOnEachRound == true
                || { () -> Bool in
                    let matchRange: ClosedRange = 0...99
                    let matchValue: Int = matchRange.randomElement()!
                    return matchValue.isMultiple(of: Setting.ExtraWeapon.isMultipleOf)
                }() == true
        else { return }
        // B - Prompt the user
        let box: String = "🎁,📦,🧺".components(separatedBy: ",").randomElement()!
        let teaseText: String = """
            Oh ! \(toon.getPicWithName()) was about to play but...
            A ✨mysterious✨ \(box) just popped out from a ☁️ !\n
            It might contains a better weapon 👍 or a weaker one 👎 :
            """
        let promptText: String = """
            1. 🔓 I want to open the \(box) and try its ✨mysterious✨ weapon
            2. 🔒 Naaaah, I'm all right with the \(toon.weapon!.getPicWithName())
            """.withNum()
        Console.write(0, 1, teaseText + "\n" + promptText, 1)
        // C - Execute
        let openTheBoxPrompt = Console.getIntInput(fromTo: 1...2)
        guard openTheBoxPrompt == 1 else { return }
        _toonGetNewWeapon(forToon: toon, fromBox: box)
        return
    }
    
    static func spreadVirus(from attacker: Toon, to defender: Toon) {
        guard let extraWeapon = attacker.weapon! as? ExtraWeapon else { return }
        if extraWeapon.type == .isBonusDisease { defender.lifeSet.isSick = true }
    }
    
    static func handleAfterFightExtraData(inGame game: Game) {
        let previousWeaponText: String? = _getPreviousWeapon()
        let virusText: String? = _applyVirusOnEachRound(inGame: game)
        switch (previousWeaponText, virusText) {
        case let (.some(weapon), .some(sickness)):
            Console.write(0, 2, weapon + sickness, 0)
        case let (.some(weapon), .none):
            Console.write(0, 2, weapon, 0)
        case let (.none, .some(sickness)):
            Console.write(0, 2, sickness, 0)
        default: return
        }
    }
    private static func _getPreviousWeapon() -> String? {
        var previousWeaponText: String = ""
        for save in _weaponSaver { // Single value
            save.toon.weapon = save.previousWeapon
            let toon = save.toon.getPicWithName()
            let weapon = save.toon.weapon!.getPicWithName()
            previousWeaponText += "ℹ️. \(toon) just got back \(save.toon.getHisOrHer())\(weapon)\n"
        }
        _weaponSaver.removeAll()
        return previousWeaponText.count > 0 ? previousWeaponText : nil
    }
    private static func _applyVirusOnEachRound(inGame game: Game) -> String? {
        let players: [Player] = [game.attackingPlayer, game.defendingPlayer]
        var sicknessText: String = ""
        for player in players {
            for toon in player.toons {
                if toon.isAlive() && toon.isSick() {
                    let toonHitpoints: Int = toon.getHitPointsLeft()
                    let damage: Int = Int(Double(toonHitpoints) * sickMultiplicator)
                    toon.loseHP(from: nil, for: damage)
                    sicknessText += "ℹ️. \(toon.getPicWithName()) is sick and just lost \(damage) HP to \(toon.getPercentLeft())%\n"
                }
            }
        }
        return sicknessText.count > 0 ? sicknessText : nil
    }
    
    // MARK: Private internal actions
    private static var _weaponSaver: [(toon: Toon, previousWeapon: Weapon)] = []
    private static func _toonGetNewWeapon(forToon toon:Toon, fromBox box:String) {
        _weaponSaver.append((toon, toon.weapon!)) // Save real weapon
        toon.weapon = _getRandomWeapon() // Get extra weapon
        let message: String = "\(toon.getPicWithName()) opened the \(box) and found a \(toon.weapon!.getPicWithName()) :"
        let newWeapon: ExtraWeapon = toon.weapon as! ExtraWeapon
        let help: String = newWeapon.type == .isBonusDisease ?
            "The \(toon.weapon!.getPicWithName()) takes \(sickPercentPenalty)% HP each round until medicine is given 👍" :
            "This \(toon.weapon!.getPicWithName()) lost its venomousness since last fullmoon 👎"
        Console.write(0, 1, "\(message)\n\(help)", 1)
    }
    private static func _getRandomWeapon() -> ExtraWeapon {
        var extraWeapons: [ExtraWeapon] = []
        extraWeapons.append(ExtraWeapon(withPic: "🦠", withName: "Vicious Virus", withType: .isBonusDisease))
        extraWeapons.append(ExtraWeapon(withPic: "🍄", withName: "FullMoon Shroom", withType: .isMalus))
        extraWeapons.shuffle()
        return extraWeapons.randomElement()!
    }
    
}
